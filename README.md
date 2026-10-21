# Orca Orchestrator

本仓库仅包含 `orca-orchestrator` 一个 skill，用于通过 Orca 协调和监督 Claude Code、Codex、OMP 执行任务。

## 文件结构

- [`orca-orchestrator/SKILL.md`](orca-orchestrator/SKILL.md)：角色确认、技能调用、任务分派、监督与验收。
- [`orca-orchestrator/references/skill-routing.md`](orca-orchestrator/references/skill-routing.md)：按任务选择技能，以及跨执行端交接规则。
- [`orca-orchestrator/agents/openai.yaml`](orca-orchestrator/agents/openai.yaml)：展示名称、简介和默认提示词。

## 使用方式

将 `orca-orchestrator/` 目录安装到所用执行端的技能目录，再调用 `orca-orchestrator`。实际编排需要可用的 Orca CLI，并按 skill 指引读取本机版本对应的运行协议。

路由文件中提到的其他 skills 不包含在本仓库中，是否调用取决于任务及执行环境的实际安装情况。

## 许可证

MIT
