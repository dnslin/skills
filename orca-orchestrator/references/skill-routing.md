# Skill Routing

Select skills by task, using installed descriptions, invocation policies, and project rules. User-required skills take priority. This is a routing guide, not a mandatory sequence.

## Discover locally

**Use skills available to the current harness, not this GitHub repository's directory list.** Coordinator and workers discover skills in their own environments:

1. Start with session-provided catalogs, read paths, and project conventions. Read `using-agent-skills` when available.
2. Inspect configured shared, user, and project skill directories as needed. On the user's machine: shared `~/.agents/skills/`, Codex `~/.codex/skills/`, Claude Code `~/.claude/skills/`. Follow directory links. Determine OMP paths from its configuration or session.
3. Use only currently enabled system/plugin catalogs. Match names, descriptions, and invocation policies before loading relevant bodies and references. Resolve duplicate names through the harness's actual lookup and pass that read path in dispatches.
4. Rediscovery takes precedence after local additions, removals, or updates. The table below reflects verified local skills; match unlisted skills by description too.

**Done:** Selected skills have real local read paths; unverified worker paths are marked pending.

## Decide invocation

For each phase, determine:

1. **Trigger:** Does the task match the skill's description?
2. **Permission:** Check frontmatter, body, and applicable `agents/openai.yaml`. `disable-model-invocation: true`, `policy.allow_implicit_invocation: false`, or an explicit-only instruction requires user invocation.
3. **Owner:** Which session needs it: Coordinator, implementer, diagnostician, or reviewer?
4. **Capability:** Can that session read the body/references and access required tools/services?

Record `applied` only when that session actually reads and applies the skill. Coordinator-only loading or dispatch mentions remain `planned`; missing text/tools are `unavailable` or `blocked`.

## Orca entry points

| Task | Entry | Owner / condition |
| --- | --- | --- |
| Supervised Run / Task / Dispatch coordination | Orca's `orchestration` skill, then the version guide returned by `skills get orchestration` | Coordinator; verify CLI/runtime |
| Valid worker Task / Dispatch preamble | Orca-injected worker protocol | Worker; follow it without creating another Run |
| Ownership transfer without supervision | Orca's `orca-cli` / handoff guidance | Current owner; no supervision loop |

Use the installed Orca version's protocol; keep version-specific command manuals outside this skill.

## Match local skills to tasks

These entries were verified locally. Read their current descriptions and restrictions before use. Multiple skills in a row serve different concerns; select those relevant to the task.

| Trigger | Local skill entry | Owner |
| --- | --- | --- |
| Missing goals, constraints, or tradeoffs affecting delivery | `interview-me`; explore alternatives with `idea-refine` | Coordinator |
| Nontrivial change lacks behavior or acceptance criteria | `spec-driven-development` | Coordinator |
| Task breakdown, dependencies, or parallel ownership | `planning-and-task-breakdown` | Coordinator |
| Project context or quality thresholds | `context-engineering`, `constraint-driven-development` | Coordinator / configuration worker |
| Implementation across files or increments | `incremental-implementation` | Implementer |
| API, module interface, or request/response contracts | `api-and-interface-design` | Designer / implementer |
| Frontend layout, state, or accessibility | `frontend-ui-engineering`; visual direction via `frontend-design` or `ui-design-guided` | UI worker |
| Information hierarchy, naming, or interaction clarity | `design-with-clarity` | Designer / reviewer |
| Read-only UI audit and improvement plan | `improve-ui`; guideline compliance via `web-design-guidelines` | UI reviewer |
| Find existing UI components, animations, or effects | `ui-search` | UI researcher / implementer |
| React / Next.js implementation or review | `vercel-react-best-practices` | Implementer / reviewer |
| Go development, review, debugging, or setup | `golang-how-to`, then its relevant local `golang-*` skills | Assigned worker |
| Swift development, review, or migration | `write-swift` | Assigned worker |
| Web / Expo motion implementation or whole-project motion audit | `animate`, `animate-expo`, `improve-animations`; relevant local `gsap-*` skills for GSAP | Motion implementer / reviewer |
| Animation or interaction-motion code review | `review-animations` | Motion reviewer |
| Third-party libraries, SDKs, or technical usage verification | `source-driven-development` | Researcher / implementer |
| Failing tests, regressions, or unexpected behavior | `debugging-and-error-recovery` | Diagnostician / implementer |
| Logic implementation, bug fixes, or behavior changes | `test-driven-development` | Implementer / tester |
| Real browser interaction or runtime evidence | Match local browser skills to tool requirements; `browser-testing-with-devtools` for DevTools checks | Verifier |
| Correctness/maintainability review or code simplification | `code-review-and-quality`, `code-simplification` | Reviewer / implementer |
| Strict review of abstractions, oversized files, or branching complexity | `thermo-nuclear-code-quality-review` | Code reviewer |
| Authentication, permissions, external input, or storage boundaries | `security-and-hardening` | Implementer / reviewer |
| Performance requirements or identified bottlenecks | `performance-optimization` | Diagnostician / implementer |
| Logs, metrics, traces, or runtime observability | `observability-and-instrumentation` | Implementer |
| Commits, branches, or Git changes | `git-workflow-and-versioning` | Change owner |
| Build or deployment pipelines | `ci-cd-and-automation` | Configuration worker |
| Migrating or deprecating interfaces/data structures | `deprecation-and-migration` | Designer / implementer |
| Public interfaces, architecture decisions, or delivery documentation | `documentation-and-adrs` | Assigned worker |
| Skills, `AGENTS.md`, or `CLAUDE.md` authoring | `writing-for-agents`; harness-resolved `skill-creator` for creation/validation | Instruction author |
| Authorized launch preparation or release | `shipping-and-launch` | Coordinator / release worker |

For design tools, images, diagrams, documents, and other specialized outputs, match local and enabled-plugin descriptions to the deliverable and available tools.

Local `prototype`, `pick-ui-library`, and `show-me` remain explicit-only. Invoke them only when the user explicitly calls them; check current policies for all other skills too.

Combine skills only for distinct responsibilities. Keep small tasks small while honoring each skill's required approvals, checks, and outputs.

## Cross-CLI handoff

Coordinator and workers may use different Claude Code, Codex, or OMP sessions, workspaces, or hosts.

1. **Read locally first:** Workers read required `SKILL.md` files and references from their own accessible directories, then report application.
2. **Share when needed:** If local access is missing, pass authorized full required content and sources through reachable files or self-contained task instructions.
3. **Verify tools separately:** Text transfer does not provide MCP, browsers, network, filesystem permissions, or credentials.
4. **Handle absence:** Block affected tasks when an explicit user requirement, project rule, or indispensable capability cannot be met. For optional skills, use an appropriate basic method and report non-use.

Worker handoffs need only:

```text
Skills applied:  Skills actually read/applied, with sources
Skills skipped:  Planned but unused skills, with reasons
Tools verified:  Actual capability/environment checks
Evidence:        Commands, artifacts, results matching acceptance criteria
```

## Recheck proportionately

Check selection reasons before dispatch and actual application at completion. Reuse skills already loaded in the same phase unless task conditions change. Reroute for new tasks, domains, or environments.
