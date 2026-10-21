# Skill Routing

本文件提供 **Coordinator 的选择规则**，不是一套必须依次运行的工作流。先发现实际安装的 skills、读取其 frontmatter 和运行约束，再决定是否调用。用户要求的 skills 优先；项目已有规则与所选 skill 的自身协议也必须遵守。

## 从本地发现技能

**路由来源是当前执行端实际可用的本地 skills，不是本 GitHub 仓库的目录清单。** 主控和 worker 分别在自己的执行环境中发现技能：

1. 先使用当前会话公布的技能目录、读取入口和项目约定；`using-agent-skills` 可用时，读取其发现流程。
2. 需要补充发现时，检查执行端实际配置的共享、用户和项目技能目录。在用户当前机器上，共享目录是 `~/.agents/skills/`，Codex 用户目录是 `~/.codex/skills/`，Claude Code 用户目录是 `~/.claude/skills/`；链接目录按实际指向读取。OMP 的目录从其当前配置或会话中确认。
3. 系统和插件技能以当前会话启用的清单为准。先看名称、描述和调用限制，再读取匹配任务的正文与必读引用；同名技能使用执行端实际解析的路径，并在派工时提供该入口。
4. 本地新增、删除或更新技能后，以新发现的内容为准。下表是按用户本地技能整理的任务入口，不是固定白名单；表外技能同样按描述匹配。

**完成标准：** 为当前任务选出的技能有真实的本地读取入口；尚未在 worker 环境核实的入口明确标记为待核实。

## 调用判定

对每个阶段，只回答四个问题：

1. **触发**：本次任务是否真的属于 skill 描述的工作？
2. **调用权**：读取 frontmatter、正文和适用的 `agents/openai.yaml`；`disable-model-invocation: true`、`policy.allow_implicit_invocation: false` 或明确的仅显式调用说明，都要求用户显式调用。
3. **承担者**：主控、实施 worker、诊断 worker、审查 worker，哪个会话需要它？
4. **可执行**：该会话能否读取正文及引用、访问所需命令与服务？

只有该会话**实际读取并应用**技能要求，才能记录 `applied`。只在主控加载过或在派工说明中提及，记录为 `planned`；缺少正文/工具则标记 `unavailable` 或 `blocked`，不要冒充完成。

## Orca 的必经入口

| 情况 | 入口 | 责任与条件 |
| --- | --- | --- |
| 需要 Orca 的 Run / Task / Dispatch 监督编排 | Orca 自带 `orchestration` skill，随后读取 `skills get orchestration` 返回的版本指南 | Coordinator；先确认 CLI 和运行时 |
| 已收到有效 worker Task / Dispatch 前言 | Orca 注入的 worker 协议 | Worker；按前言处理，不另起 Run |
| 仅移交工作而不监督 | Orca 的 `orca-cli` / handoff 指引 | 当前所有者；不创建无意义的监督循环 |

Orca 的运行协议以**当前安装版本**为准。不要复制固定版本的命令表到本 skill。

## 按本地技能匹配任务

以下入口已在用户本机技能目录中核实。执行时仍需读取当前版本的描述和限制；同一行的多个名称分别解决不同问题，按任务选择。

| 触发条件 | 本地技能入口 | 责任会话 |
| --- | --- | --- |
| 缺少会影响交付的目标、约束或取舍 | `interview-me`；需要探索方案时用 `idea-refine` | 主控 |
| 非平凡变更缺少行为约定或验收条件 | `spec-driven-development` | 主控 |
| 需要拆解任务、依赖和并行修改边界 | `planning-and-task-breakdown` | 主控 |
| 需要配置项目上下文或明确质量门槛 | `context-engineering`、`constraint-driven-development` | 主控或配置 worker |
| 实施跨文件或多个增量的变更 | `incremental-implementation` | 实施 worker |
| 设计 API、模块接口或请求响应契约 | `api-and-interface-design` | 设计或实施 worker |
| 实现前端界面、布局、状态和可访问性 | `frontend-ui-engineering`；视觉方向按任务选 `frontend-design` 或 `ui-design-guided` | UI worker |
| 改进信息层级、命名和交互表达 | `design-with-clarity` | 设计或审查 worker |
| 只读审查现有 UI 并形成改进计划 | `improve-ui`；规范符合性检查用 `web-design-guidelines` | UI reviewer |
| 需要检索现有 UI 组件、动画或效果 | `ui-search` | UI 调研或实施 worker |
| 编写或审查 React / Next.js | `vercel-react-best-practices` | 实施或审查 worker |
| Go 开发、审查、调试或配置 | `golang-how-to`，再按其路由选择本地 `golang-*` 技能 | 对应 worker |
| Swift 开发、审查或迁移 | `write-swift` | 对应 worker |
| 新增 Web / Expo 动效，或审查全项目动效 | `animate`、`animate-expo`、`improve-animations`；GSAP 按具体功能选本地 `gsap-*` 技能 | 动效实施或审查 worker |
| 使用第三方库、SDK 或需要核实技术用法 | `source-driven-development` | 调研或实施 worker |
| 出现测试失败、回归或异常行为 | `debugging-and-error-recovery` | 诊断或实施 worker |
| 实现逻辑、修复缺陷或修改行为 | `test-driven-development` | 实施或测试 worker |
| 需要真实浏览器操作或运行证据 | 从本地浏览器技能的描述和工具要求选择；DevTools 检查可用 `browser-testing-with-devtools` | 验证 worker |
| 审查代码正确性与可维护性，或简化现有代码 | `code-review-and-quality`、`code-simplification` | reviewer 或实施 worker |
| 涉及认证、权限、外部输入或存储边界 | `security-and-hardening` | 实施或审查 worker |
| 有性能要求或已发现瓶颈 | `performance-optimization` | 诊断或实施 worker |
| 需要日志、指标、追踪等运行证据 | `observability-and-instrumentation` | 实施 worker |
| 提交、分支或处理 Git 变更 | `git-workflow-and-versioning` | 持有变更的会话 |
| 修改构建和部署流水线 | `ci-cd-and-automation` | 配置 worker |
| 迁移或废弃既有接口与数据结构 | `deprecation-and-migration` | 设计或实施 worker |
| 记录公共接口、架构决策或交付文档 | `documentation-and-adrs` | 对应 worker |
| 创建或修改 skill、`AGENTS.md`、`CLAUDE.md` | `writing-for-agents`；技能创建与校验用当前执行端的 `skill-creator` | 指令编写 worker |
| 已获授权的上线准备或发布 | `shipping-and-launch` | 主控或发布 worker |

设计工具、图像、图表、文档等专门任务，继续检索本地及当前启用插件的描述，选择符合产物和工具要求的技能。

本地的 `prototype`、`pick-ui-library`、`review-animations`、`thermo-nuclear-code-quality-review`、`show-me` 标记为仅显式调用。只有用户明确调用相应技能时才启用；其他技能也以其当前调用限制为准。

一个任务可用多个 skill，但要有不同职责；一项小改动不应因为存在许多可用技能就被扩充成庞大的流程。技能本身要求的用户确认、检查步骤和产出不能因编排而省略。

## 跨 CLI 交接

主控与 worker 可能运行于 Claude Code、Codex、OMP 不同的会话、工作区乃至主机上。

1. **首先就地读取：** worker 从自己的可用技能目录读取相应的 `SKILL.md` 和必读引用，并报告已应用。
2. **无法就地读取：** 主控仅在有权限且实际可达时，把完整必需内容和来源传到 worker 可读取的位置，或将具体文本纳入独立任务资料。
3. **单独核实工具：** 技能正文的传递不能替代 MCP、浏览器、网络访问、文件读写权限或认证凭据。
4. **阻塞策略：** 用户显式要求、项目规则规定、或完成任务不可替代的必需技能不可用时，停止受影响任务并说明缺失；其他可选技能不可用时采用基本方法并如实说明。

worker 的 handoff 包含下面四项即可，无需转述整个技能全文：

```text
Skills applied:  已实际读取与应用的技能及其来源
Skills skipped:  计划但未使用的技能及理由
Tools verified:  必要工具/环境的实际检查结果
Evidence:        与验收要求对应的命令、产物及结果
```

## 适度调用检查

派工前检查一次选用理由；worker 完成时检查实际应用记录。**同一阶段已加载且未发生任务条件变化的 skill 不必反复读取。** 只有新任务、新领域或执行环境变化才重新进行路由。
