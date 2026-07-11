# Skills

Claude Code 技能集合，涵盖技能管理、项目协作、代码工程、前端 UI 设计、GSAP 动画与自动化工具，共 36 个技能。

## 可用技能

### 技能管理与上下文

- **find-skills** - 发现并安装来自开放技能生态的 agent 技能
- **skill-creator** - 创建新技能、迭代优化现有技能，并可通过 eval 基准测试性能
- **init-deep** - 初始化或迁移到嵌套的 CLAUDE.md 结构，实现渐进式上下文披露
- **ask-matt** - 仓库内技能路由器，判断当前任务应使用哪个技能或流程
- **setup-matt-pocock-skills** - 为工程技能初始化仓库配置（问题追踪器、分类标签、领域文档），使用前运行一次

### 项目协作与工单

- **gh-create-issue** - 从 PRD 或需求创建结构化 GitHub Issue，自动评估复杂度并做任务拆解
- **to-spec** - 将当前对话综合提炼为一份规格说明（PRD）并发布到追踪器
- **to-tickets** - 将计划、规格或对话拆分为带阻塞依赖的工单序列
- **triage** - 通过分类、验证、质询等状态机流转问题与外部 PR，生成可直接执行的简报
- **wayfinder** - 将超大型工作规划为追踪器上的共享调查地图，逐步打通通往目标的路径
- **resolving-merge-conflicts** - 解决进行中的 git 合并/rebase 冲突，理解双方意图后妥善处理

### 研究与规划

- **research** - 针对高可信原始来源调查问题，以带引用的 Markdown 保存在仓库中
- **grill-with-docs** - 通过持续高强度访谈打磨计划或设计，同步生成 ADR 与术语表
- **domain-modeling** - 构建并打磨领域模型，确立术语统一语言、记录架构决策
- **prototype** - 构建一次性原型验证状态模型/逻辑，或探索 UI 应有的形态

### 代码工程

- **implement** - 根据规格或工单实施开发，配合 TDD、类型检查与代码审查完成提交
- **tdd** - 采用红-绿循环的测试驱动开发方法构建功能或修复 Bug
- **code-review** - 从提交/分支/标签起审查代码变更，沿规范与规格两维度并行审查并汇总
- **diagnosing-bugs** - 针对难排查的 Bug 与性能回归提供诊断循环流程
- **codebase-design** - 为深度模块设计提供共享词汇表，用于改进接口、寻找深化机会
- **improve-codebase-architecture** - 扫描代码库寻找架构深化机会，以可视化 HTML 报告呈现

### 前端与 UI 设计

- **ui-design-guided** - 引导式 UI 设计工作流，构建生产级、有辨识度的前端界面
- **ui-search** - 从 Aceternity UI、Magic UI、UI Layouts、ReactBits 检索前端组件
- **frontend-design** - 提供独特、有意图的视觉设计指导，避免模板化的默认选择
- **web-design-guidelines** - 审查 UI 代码是否符合可访问性、设计一致性与 UX 最佳实践
- **react-best-practices** - 来自 Vercel 工程团队的 React/Next.js 性能优化指南

### GSAP 动画

- **gsap-core** - 核心 API（to/from/fromTo、缓动、时长、stagger、matchMedia）
- **gsap-timeline** - 时间线编排（timeline、position 参数、嵌套与回放）
- **gsap-scrolltrigger** - 滚动联动动画、元素固定、scrub 同步与视差效果
- **gsap-react** - 在 React/Next.js 中使用 useGSAP、refs、context 及卸载清理
- **gsap-frameworks** - Vue、Svelte 等非 React 框架的生命周期与清理
- **gsap-plugins** - ScrollToPlugin、Flip、Draggable、SplitText、CustomEase 等插件
- **gsap-performance** - transforms 优先、避免布局抖动、批处理实现流畅 60fps
- **gsap-utils** - clamp、mapRange、random、snap、wrap、pipe 等工具函数

### 自动化与媒体

- **gpt-imagegen** - 通过 OpenAI 兼容 API 进行文生图、改图、合成与 4K 拼接
- **agent-browser** - 面向 AI agent 的浏览器自动化 CLI，支持导航、填表、点击、截图、数据提取

## 使用方式

每个技能是一个独立目录，包含定义其行为的 `SKILL.md` 文件。可将单个技能安装到 Claude Code 环境中，或作为构建自定义工作流的参考。

## 许可证

MIT
