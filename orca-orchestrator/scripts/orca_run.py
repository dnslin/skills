#!/usr/bin/env python3
"""Maintain an Orca run folder: ledger, report checks, context staleness, archiving,
and refine notes (small, logged, revertible harness changes).

Agents call these commands instead of editing ledger.json by hand.
Standard library only. Exit code 1 means a check failed or input was invalid.
"""
import argparse
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
BRIEF_TEMPLATE = SKILL_DIR / "references" / "run-template" / "brief.md"
STATUSES = ["planned", "dispatched", "review", "accepted", "rejected", "failed", "archived"]
REPORT_SECTIONS = ["Verdict", "Commits", "Changes", "Evidence", "Decisions made", "Open issues", "Details"]
VERDICTS = {"succeeded", "failed", "partial"}
MAX_SUMMARY_LINES = 30
MAX_DECISION_LINES = 30
REWORK_LIMIT = 2
MAX_NOTE_CHARS = 400
PROJECT_NOTES_HEADER = """# Project notes

Persistent across runs; every worker reads this file first.
Changed only through `orca_run.py refine-add --scope project`; each block can be reverted by its id.
"""
HARNESS_NOTES_HEADER = """# Harness notes for this run

Supplements to the brief and specs for this run only; every worker reads this file first.
Changed only through `orca_run.py refine-add --scope run`; each block can be reverted by its id.
"""


def fail(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%MZ")


def load(run):
    path = Path(run) / "ledger.json"
    if not path.exists():
        fail(f"no ledger at {path}; run init first")
    return json.loads(path.read_text())


def save(run, ledger):
    path = Path(run) / "ledger.json"
    tmp = path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(ledger, ensure_ascii=False, indent=2) + "\n")
    tmp.replace(path)


def git(cwd, *args):
    try:
        out = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, check=True)
        return out.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def cmd_init(a):
    root = Path(a.workspace).resolve()
    run = root / ".orca-run" / a.run_id
    if run.exists():
        fail(f"{run} already exists")
    base = a.base or git(root, "branch", "--show-current")
    if git(root, "rev-parse", "--git-dir") and not base:
        fail("cannot detect the brain's branch (detached HEAD?); pass --base <branch>")
    for sub in ("context", "tasks", "reports", "archive"):
        (run / sub).mkdir(parents=True)
    brief = BRIEF_TEMPLATE.read_text().replace("<objective>", a.objective).replace("<base_branch>", base or "none (not a git repo)")
    (run / "brief.md").write_text(brief)
    (run / "harness-notes.md").write_text(HARNESS_NOTES_HEADER)
    notes = root / ".orca-run" / "project-notes.md"
    if not notes.exists():
        notes.write_text(PROJECT_NOTES_HEADER)
    save(run, {"run_id": a.run_id, "workspace": str(root), "base_branch": base, "created": now(), "tasks": {}})
    git_dir = git(root, "rev-parse", "--git-common-dir")
    if git_dir:
        exclude = (root / git_dir / "info" / "exclude").resolve()
        exclude.parent.mkdir(parents=True, exist_ok=True)
        lines = exclude.read_text().splitlines() if exclude.exists() else []
        if ".orca-run/" not in lines:
            with exclude.open("a") as f:
                f.write(".orca-run/\n")
    print(run)


def cmd_task_add(a):
    ledger = load(a.run)
    if a.slug in ledger["tasks"]:
        fail(f"task {a.slug} exists")
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]{0,48}", a.slug):
        fail("slug must be lowercase letters, digits, and hyphens")
    ledger["tasks"][a.slug] = {
        "status": "planned", "agent": a.agent, "why": a.why, "orca_task": a.orca_task,
        "context": [c for c in (a.context or "").split(",") if c],
        "dispatch": None, "model": None, "branch": None, "commits": [], "report": None, "pr": None,
        "result": None, "rework": 0, "updated": now(),
    }
    save(a.run, ledger)
    print(f"added {a.slug}")


def cmd_task_set(a):
    ledger = load(a.run)
    task = ledger["tasks"].get(a.slug) or fail(f"no task {a.slug}")
    if a.status:
        if a.status not in STATUSES:
            fail(f"status must be one of {', '.join(STATUSES)}")
        if a.status == "archived":
            fail("use the archive command")
        task["status"] = a.status
    for field in ("dispatch", "model", "branch", "report", "result", "orca_task", "pr"):
        value = getattr(a, field)
        if value is not None:
            task[field] = value
    if a.commits:
        task["commits"] = a.commits.split(",")
    if a.rework:
        task["rework"] += 1
    task["updated"] = now()
    save(a.run, ledger)
    if task["rework"] >= REWORK_LIMIT and task["status"] == "rejected":
        print(f"warning: {a.slug} rejected {task['rework']} times; change approach, agent, or task boundary, or escalate")
    print(f"{a.slug}: {task['status']}")


def section(text, name):
    match = re.search(rf"^## {re.escape(name)}\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    return match.group(1).strip() if match else None


def cmd_show(a):
    run = Path(a.run)
    ledger = load(run)
    print(f"base branch: {ledger.get('base_branch') or '-'}")
    rows = [(s, t) for s, t in ledger["tasks"].items() if a.all or t["status"] != "archived"]
    for slug, t in rows:
        model = t["model"] or "?"
        pr = t.get("pr") or "-"
        print(f"{slug} | {t['status']} | {t['agent']}/{model} | rework {t['rework']} | pr {pr} | {t['result'] or '-'}")
    archived = sum(1 for t in ledger["tasks"].values() if t["status"] == "archived")
    if not a.all and archived:
        print(f"({archived} archived)")
    decisions = section((run / "brief.md").read_text(), "Decisions") or ""
    count = len([l for l in decisions.splitlines() if l.strip() and not l.startswith("<!--")])
    if count > MAX_DECISION_LINES:
        print(f"warning: brief Decisions has {count} lines; summarize old ones and move them to archive/decisions.md")


def cmd_check_report(a):
    text = Path(a.path).read_text()
    found = re.findall(r"^## (.+?)\s*$", text, re.M)
    errors = []
    if found != REPORT_SECTIONS:
        errors.append(f"headings must be exactly, in order: {', '.join(REPORT_SECTIONS)}; found: {', '.join(found)}")
    else:
        verdict = section(text, "Verdict").lower()
        if verdict not in VERDICTS:
            errors.append(f"Verdict must be one of {', '.join(sorted(VERDICTS))}")
        commits = section(text, "Commits")
        if verdict != "failed" and not commits.lower().startswith("none") and not re.search(r"\b[0-9a-f]{7,40}\b", commits):
            errors.append("Commits needs 'Branch: <name>' and SHAs, or 'none - <reason>' for read-only work")
        summary = text.split("## Details", 1)[0]
        lines = [l for l in summary.splitlines() if l.strip() and not l.startswith("## ")]
        if len(lines) > MAX_SUMMARY_LINES:
            errors.append(f"sections above Details have {len(lines)} lines; limit {MAX_SUMMARY_LINES}, move detail under Details")
    for e in errors:
        print(f"report invalid: {e}")
    if errors:
        sys.exit(1)
    print("report ok")


def cmd_check_context(a):
    run = Path(a.run)
    ledger = load(run)
    workspace = ledger["workspace"]
    stale = 0
    for path in sorted((run / "context").glob("*.md")):
        text = path.read_text()
        base = re.search(r"^Base:\s*([0-9a-f]{7,40})", text, re.M)
        if not base:
            print(f"{path.name}: no 'Base: <sha>' line")
            stale += 1
            continue
        changed = git(workspace, "diff", "--name-only", f"{base.group(1)}..HEAD")
        if changed is None:
            print(f"{path.name}: cannot compare (not git or unknown sha)")
            continue
        cited = set(re.findall(r"([\w./-]+\.\w+):\d+", text))
        hit = sorted(cited & set(changed.splitlines()))
        if hit:
            stale += 1
            print(f"{path.name}: stale, changed since {base.group(1)[:7]}: {', '.join(hit[:5])}")
    if stale:
        sys.exit(1)
    print("context ok")


def cmd_archive(a):
    run = Path(a.run)
    ledger = load(run)
    task = ledger["tasks"].get(a.slug) or fail(f"no task {a.slug}")
    if task["status"] not in ("accepted", "failed") and not a.force:
        fail(f"{a.slug} is {task['status']}; only accepted or failed tasks are archived")
    dest = run / "archive" / a.slug
    dest.mkdir(parents=True, exist_ok=True)
    moved = []
    plan = run / "tasks" / f"{a.slug}.md"
    if plan.exists():
        shutil.move(str(plan), dest / "plan.md")
        moved.append("plan.md")
    for path in sorted((run / "reports").glob(f"{a.slug}*.md")):
        shutil.move(str(path), dest / path.name)
        moved.append(path.name)
    task["status"] = "archived"
    task["report"] = str(dest / f"{a.slug}.md") if f"{a.slug}.md" in moved else task["report"]
    task["updated"] = now()
    active_context = {c for t in ledger["tasks"].values() if t["status"] != "archived" for c in t["context"]}
    for path in sorted((run / "context").glob("*.md")):
        if path.stem not in active_context and path.stem in task["context"]:
            shutil.move(str(path), run / "archive" / path.name)
            moved.append(f"context/{path.name}")
    save(run, ledger)
    print(f"archived {a.slug}: {', '.join(moved) or 'no files'}")


def cmd_close(a):
    run = Path(a.run).resolve()
    ledger = load(run)
    open_tasks = [s for s, t in ledger["tasks"].items() if t["status"] not in ("archived", "accepted", "failed")]
    if open_tasks and not a.force:
        fail(f"open tasks: {', '.join(open_tasks)}")
    log = read_log(run.parent)
    promoted = {e["source"] for e in log if e["source"]}
    pending = [e for e in log if e["run"] == ledger["run_id"] and e["scope"] == "run" and not e["reverted"] and e["id"] not in promoted]
    archive_root = run.parent / "archive"
    archive_root.mkdir(exist_ok=True)
    target = archive_root / run.name
    shutil.move(str(run), target)
    moved_ledger = load(target)
    for t in moved_ledger["tasks"].values():
        if t.get("report"):
            t["report"] = t["report"].replace(str(run), str(target), 1)
    save(target, moved_ledger)
    entries = read_log(run.parent)
    for e in entries:
        if e.get("file", "").startswith(str(run)):
            e["file"] = e["file"].replace(str(run), str(target), 1)
    if entries:
        write_log(run.parent, entries)
    runs = sorted((p for p in archive_root.iterdir() if p.is_dir()), key=lambda p: p.stat().st_mtime, reverse=True)
    print(f"closed {run.name} -> {archive_root / run.name}")
    for old in runs[a.keep:]:
        print(f"delete candidate (ask the user first): {old}")
    for e in pending:
        print(f"promotion candidate {e['id']} ({e['result'] or 'no result'}): {e['note'][:80]}")


def orca_root_of(run):
    """The .orca-run folder that holds this run, before or after close."""
    run = Path(run).resolve()
    return run.parent.parent if run.parent.name == "archive" else run.parent


def log_path(orca_root):
    return Path(orca_root) / "refine-log.jsonl"


def read_log(orca_root):
    path = log_path(orca_root)
    if not path.exists():
        return []
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def write_log(orca_root, entries):
    path = log_path(orca_root)
    tmp = path.with_suffix(".jsonl.tmp")
    tmp.write_text("".join(json.dumps(e, ensure_ascii=False) + "\n" for e in entries))
    tmp.replace(path)


def find_entry(entries, entry_id):
    for e in entries:
        if e["id"] == entry_id:
            return e
    fail(f"no refine entry {entry_id}")


def append_note(run, ledger, scope, trigger, note, source=None):
    if len(note) > MAX_NOTE_CHARS or "\n\n" in note:
        fail(f"a refine note is one small change: at most {MAX_NOTE_CHARS} characters, one paragraph")
    orca_root = orca_root_of(run)
    target = Path(run) / "harness-notes.md" if scope == "run" else orca_root / "project-notes.md"
    entries = read_log(orca_root)
    entry_id = f"r{len(entries) + 1}"
    with target.open("a") as f:
        f.write(f"\n<!-- refine:{entry_id} -->\n- {note}\n<!-- /refine:{entry_id} -->\n")
    entries.append({
        "id": entry_id, "time": now(), "run": ledger["run_id"], "scope": scope, "file": str(target),
        "trigger": trigger, "note": note, "source": source, "result": None, "reverted": False,
    })
    write_log(orca_root, entries)
    return entry_id, target


def cmd_refine_add(a):
    ledger = load(a.run)
    entry_id, target = append_note(a.run, ledger, a.scope, a.trigger, a.note)
    print(f"{entry_id} -> {target}")


def cmd_refine_result(a):
    orca_root = orca_root_of(a.run)
    entries = read_log(orca_root)
    find_entry(entries, a.id)["result"] = a.result
    write_log(orca_root, entries)
    print(f"{a.id}: {a.result}")


def cmd_refine_revert(a):
    orca_root = orca_root_of(a.run)
    entries = read_log(orca_root)
    entry = find_entry(entries, a.id)
    if entry["reverted"]:
        fail(f"{a.id} already reverted")
    path = Path(entry["file"])
    text = path.read_text()
    block = re.compile(rf"\n<!-- refine:{re.escape(a.id)} -->\n.*?<!-- /refine:{re.escape(a.id)} -->\n", re.S)
    new, count = block.subn("", text)
    if count != 1:
        fail(f"block for {a.id} not found in {path}; it was edited by hand")
    path.write_text(new)
    entry["reverted"] = True
    write_log(orca_root, entries)
    print(f"reverted {a.id} from {path}")


def cmd_refine_promote(a):
    ledger = load(a.run)
    entries = read_log(orca_root_of(a.run))
    entry = find_entry(entries, a.id)
    if entry["scope"] != "run" or entry["reverted"]:
        fail("only active run-scope notes can be promoted")
    entry_id, target = append_note(a.run, ledger, "project", f"promoted from {a.id}: {entry['trigger']}", entry["note"], source=a.id)
    print(f"{entry_id} -> {target}")


def cmd_refine_list(a):
    entries = read_log(orca_root_of(a.run))
    for e in entries:
        if a.active and e["reverted"]:
            continue
        state = "reverted" if e["reverted"] else (e["result"] or "no result")
        print(f"{e['id']} | {e['scope']} | {e['run']} | {state} | {e['trigger'][:50]} | {e['note'][:70]}")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("init", help="create a run folder")
    s.add_argument("workspace"); s.add_argument("run_id"); s.add_argument("--objective", required=True)
    s.add_argument("--base", help="branch PRs target; defaults to the brain's current branch")
    s.set_defaults(fn=cmd_init)

    s = sub.add_parser("task-add", help="register a task")
    s.add_argument("--run", required=True); s.add_argument("--slug", required=True)
    s.add_argument("--agent", required=True); s.add_argument("--why", required=True)
    s.add_argument("--orca-task", dest="orca_task"); s.add_argument("--context", help="comma-separated context topics")
    s.set_defaults(fn=cmd_task_add)

    s = sub.add_parser("task-set", help="update a task")
    s.add_argument("--run", required=True); s.add_argument("--slug", required=True)
    s.add_argument("--status"); s.add_argument("--dispatch"); s.add_argument("--model")
    s.add_argument("--branch"); s.add_argument("--commits"); s.add_argument("--report")
    s.add_argument("--result"); s.add_argument("--orca-task", dest="orca_task")
    s.add_argument("--pr", help="URL of the pull request into the base branch")
    s.add_argument("--rework", action="store_true", help="count one more rework round")
    s.set_defaults(fn=cmd_task_set)

    s = sub.add_parser("show", help="print active tasks, one line each")
    s.add_argument("--run", required=True); s.add_argument("--all", action="store_true")
    s.set_defaults(fn=cmd_show)

    s = sub.add_parser("check-report", help="validate a worker report")
    s.add_argument("path")
    s.set_defaults(fn=cmd_check_report)

    s = sub.add_parser("check-context", help="find context files made stale by later commits")
    s.add_argument("--run", required=True)
    s.set_defaults(fn=cmd_check_context)

    s = sub.add_parser("archive", help="archive an accepted or failed task")
    s.add_argument("--run", required=True); s.add_argument("--slug", required=True)
    s.add_argument("--force", action="store_true")
    s.set_defaults(fn=cmd_archive)

    s = sub.add_parser("close", help="move the whole run into .orca-run/archive")
    s.add_argument("--run", required=True); s.add_argument("--keep", type=int, default=5)
    s.add_argument("--force", action="store_true")
    s.set_defaults(fn=cmd_close)

    s = sub.add_parser("refine-add", help="append one small, revertible harness note")
    s.add_argument("--run", required=True); s.add_argument("--scope", choices=["run", "project"], default="run")
    s.add_argument("--trigger", required=True, help="what in the trajectory caused this change")
    s.add_argument("--note", required=True)
    s.set_defaults(fn=cmd_refine_add)

    s = sub.add_parser("refine-result", help="record whether a refine note helped")
    s.add_argument("--run", required=True); s.add_argument("--id", required=True); s.add_argument("--result", required=True)
    s.set_defaults(fn=cmd_refine_result)

    s = sub.add_parser("refine-revert", help="remove a refine note")
    s.add_argument("--run", required=True); s.add_argument("--id", required=True)
    s.set_defaults(fn=cmd_refine_revert)

    s = sub.add_parser("refine-promote", help="copy a run-scope note into project notes")
    s.add_argument("--run", required=True); s.add_argument("--id", required=True)
    s.set_defaults(fn=cmd_refine_promote)

    s = sub.add_parser("refine-list", help="list refine notes, one line each")
    s.add_argument("--run", required=True); s.add_argument("--active", action="store_true")
    s.set_defaults(fn=cmd_refine_list)

    a = p.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
