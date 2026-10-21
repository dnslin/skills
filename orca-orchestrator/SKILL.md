---
name: orca-orchestrator
description: >-
  Coordinate and supervise coding agents through Orca across Claude Code, Codex,
  and OMP. Use when the user requests multi-agent orchestration, supervised
  delegation, model-aware task routing, parallel workers, independent review,
  or task-specific skill handoffs with Orca. For an unsupervised one-way
  handoff, follow Orca's ordinary handoff guidance instead.
---

# Orca Orchestrator

在 Orca 中担任 **Coordinator**：明确目标，选择执行端和模型，分派独立任务，监督结果并作出验收决策。Claude Code、Codex、OMP 都可以担任主控或 worker；**角色、执行端和模型是三个独立选择**。

## 1. 确认身份并读取运行协议

1. 如果当前会话已收到 Orca 注入的有效 Task / Dispatch 前言，则你是 **worker**。按该前言执行、提问、回报，不另建 Run 或取代主控。
2. 如果用户仅要求移交工作所有权，不要求监督、等待或验收，按 Orca 的普通 handoff 指引办理。
3. 需要监督编排时，先定位本机 Orca CLI，读取 Orca 自带的 `orchestration` skill，再用**同一可执行文件**运行 `skills get orchestration`，遵循返回的版本匹配指南。复杂分支按指南加载指定 reference。
4. 核实 Orca 实际可用及当前会话的权限。若缺少运行时或必需能力，报告具体阻塞；不要用其他 subagent、后台脚本或猜测的命令假装完成 Orca 编排。

**完成标准：** 已判定当前角色，且执行路径与当前 Orca 的真实能力一致。

## 2. 发现并主动调用所需 skills

在规划前检查当前执行端实际可读取的 skills，以及仓库的 `AGENTS.md`、`CLAUDE.md` 和已有约定。读取 [references/skill-routing.md](references/skill-routing.md)，按**任务触发条件**选择技能，而不是按固定清单全部加载。

- 如果某个可自动调用的 skill 与当前阶段匹配，由该阶段的**责任会话实际读取并应用**。只是提到技能名、主控读过、或在任务里写“请遵循”都不等于 worker 已应用。
- 遵守每个 skill 的调用限制。标记为 `disable-model-invocation: true` 的技能，只有用户显式调用时才启用。
- 对 worker 必需的 skill，先确认它能访问完整正文、必读引用和所需工具。不能访问时，提供有权限分享的材料与来源，或将该任务标记为阻塞。**传递文本不代表提供了浏览器、MCP、凭据等工具能力。**
- 普通补充 skill 不可用时，采用适合任务的基本做法并如实记录；不得伪称调用成功。

**完成标准：** 每个必要技能都有触发理由、责任会话、可读取入口及可用性结论；用户指定的必需技能不会被静默跳过。

## 3. 明确任务与选择执行配置

先确认目标、已有项目状态、约束和可观察的成功条件。用最少的任务数组织工作：紧密耦合的修改放在一个任务里；仅在修改责任清楚、可独立验收时并行。

从真实可用的 **(agent harness, model, effort)** 组合中选择 worker：

- 边界清晰、验收可运行：优先已验证能胜任且成本较低的组合。
- 存在架构权衡、复杂诊断或明确的能力不足证据：选更强的组合，或先缩小问题。
- 认证、限流、工具缺失与提示不完整：先修复相应问题，不直接解释为模型能力不足。

查询每个执行端实际支持的模型及启动参数；以当前 Orca 指南为准传递选择。**请求模型 ≠ 证实模型已生效**。若无法核实，明确记录为未知。尊重用户指定的模型、预算、审批和执行端限制。

**完成标准：** 每个任务都有明确的 owner、工作区、目标、验收方式和经核实的执行配置；不可验证的假设被标出。

## 4. 派工并监督

使用 Orca 当前版本的正常 supervised worker 流程。每份任务说明独立完整，至少包含以下字段：

```text
Target:       要处理的文件、组件或环境
Change:       必须交付的可见行为或产物
Constraints:  兼容性、安全边界、不可破坏的既有行为
Ownership:    可修改的路径、工作区/分支、与其他任务的边界
Acceptance:   具体检查方式、期望结果和证据
Skills:       必需/可选技能、worker 可访问的位置、所需工具
Handoff:      修改内容、实际验证、剩余问题与证据位置
```

worker 无法天然读取主控的聊天历史，也未必能看到其他 worktree 中尚未提交的文件。任务资料应使用 worker 确实可访问的路径、提交或摘要；保留用户已有的未提交改动。默认从一个实施 worker 开始，并行任务使用明确隔离的修改边界；worker 不自行派生子 worker，除非主控显式授权。

按 Orca 的消息/等待机制处理问题与 `worker_done`。超时、收不到消息、终端看似空闲，都不足以证明进程已退出。只有符合版本指南的积极证据才能执行停止、重试、遗弃或释放。

**完成标准：** 每个 Dispatch 的状态有 Orca 记录支持；每项产物可追踪到对应任务和执行者。

## 5. 验收、返工与收尾

根据任务合同检查真实 diff/产物、测试命令、输出和未覆盖项。worker 的完成声明是**报告**，不是需求已满足的证据。必要时采用独立的审查会话：重点用于跨模块变更、权限与安全边界、不可运行的验收条件或存在正确性疑问的结果。审查期间保持被审查候选版本稳定。

发现可定位的合同内错误，先要求一次有针对性的修复并复核；再次失败则重新规划、拆分或升级执行配置，而不是重复相同提示。涉及范围或架构变化、危险操作、权限升级、发布或合并时遵循用户授权。

根据版本匹配的 Orca 指南完成消息确认、worker 的保留/复用/释放和未结任务核对。不要把释放当成取消，也不因缺少消息就启动重复编辑者。

向用户简要报告：任务与结果、实际使用的执行端及可核实模型、真正应用的 skills、改动/产物、验证证据、未解决问题；只有获取到真实数据时才报告费用或节省比例。

**完成标准：** 全部在范围内的任务有明确结论与证据，异常和剩余工作可追踪，Orca 资源按当前协议完成处置。
