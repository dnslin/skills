# Skill Routing

Select the smallest sufficient skill set for the task. A description match identifies a candidate, not a requirement to run every matching workflow.

## Discover and select

1. Start with the current session's skill catalog and project instructions. Inspect configured skill directories only as needed; use the receiving harness's actual lookup paths, including linked directories and enabled plugins.
2. Apply skills required by the user, project, or host. For other candidates, choose complementary skills that address the task's actual needs. Reuse existing plans and evidence instead of repeating their production.
3. Read invocation restrictions in frontmatter, body, and applicable `agents/openai.yaml`. `disable-model-invocation: true`, `policy.allow_implicit_invocation: false`, and explicit-only instructions require user invocation. Selection does not override these restrictions.
4. Resolve duplicate names through the harness's lookup rules. Pass the resolved entry point to the responsible session. Reuse discoveries until the task or environment changes.

User scope and project constraints take precedence over generic skill suggestions, subject to host requirements. Keep Orca protocol discovery in the main workflow; do not maintain a second command manual or static skill inventory here.

## Apply in the responsible session

The session doing the work must read and apply the selected skill and relevant references. Coordinator-only reading or a name in the brief does not establish worker application.

Prefer locally accessible sources. If needed, share authorized required content with its source through accessible files or task instructions. Verify necessary tools separately: transferred text does not provide browsers, MCP services, credentials, or filesystem access.

When a required skill or indispensable capability is unavailable, resolve access or report the affected task as blocked. For an optional skill, use a suitable basic method and disclose non-use when it affects delivery.

Report actual skill use and consequential gaps once in the handoff. Avoid duplicate per-phase inventories or separate skill-status tracking.
