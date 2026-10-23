# design-with-clarity

用《Don't Make Me Think》和《写给大家看的设计书》的判断方法，设计、实现、改稿与评审界面及信息排版。

**先判断页面让人怎样理解，再把内容关系变成可见的设计。**

这个 skill 不以背出原则名称为验收标准。它要求关键改动能说清：当前线索可能产生什么理解，哪些内容应当关联或区分，为什么选择这项改动，以及改后如何核对。

## 它怎样工作

1. 从实际阅读、比较或操作任务出发，核对内容与产品行为。
2. 考虑扫读、尝试合理入口、边用边理解，识别“看见了却理解错”的情况。
3. 确定内容的归属、顺序、异同，再共同运用亲密性、对齐、重复和对比。
4. 将字体、文案、布局和反馈落实到这些关系；对重要方案说明实际取舍。
5. 回到同一个任务核对，区分设计假设、实现结果与真人观察。

清晰可以容纳高密度、鲜明个性和趣味。局部修正采用足够有效的改动；授权的视觉重设计可以充分调整布局与表达，不默认扩展产品功能。

## 使用

将本目录作为支持 `SKILL.md` 的 Agent Skill 导入工具，然后在任务中调用：

```text
用 $design-with-clarity 评审这个上传页面。
说明哪些可见线索可能让用户误解，并给出具体修改。
保留现有功能和品牌。
```

```text
用 $design-with-clarity 改进这个工作台。
用户要反复比较数据，请直接修改布局与表达，保留必要信息。
说明关键取舍，并检查修改涉及的状态。
```

```text
用 $design-with-clarity 重新设计这个活动页。
保留功能和现有手绘气质，借鉴参考的排版关系。
把信息组织和作品个性一起落实，不新增流程。
```

## 一个判断例子

选择封面后显示“上传成功”，但实际需要另点保存才生效。“成功”和预览可能让人以为换图已经生效，因此要核对界面表达与实际行为的差别。

skill 会先核对真实行为，再让文件选择、待保存和已生效状态准确区分，并用分组和位置表达保存的范围。改后检查用户是否仍可能在尚未保存时认为完成，而不只报告“统一了间距和字号”。完整例子见 [worked-examples.md](references/worked-examples.md)。

## 文件

- [SKILL.md](SKILL.md)：核心判断方法与执行流程。
- [references/worked-examples.md](references/worked-examples.md)：三个原创改稿案例，包含依据、取舍、验证与改变方案的条件。
- [references/visual-polish.md](references/visual-polish.md)：按问题使用的排版、色彩、形态与交互细节。
- [references/sources.md](references/sources.md)：原始资料、实际可见范围与应用归纳的区别。
- [agents/openai.yaml](agents/openai.yaml)：调用元数据。

## 来源

基础来自 Steve Krug 的 *Don't Make Me Think* 与 Robin Williams 的 *The Non-Designer's Design Book*。本仓库提供原创的应用方法，不复现全书。公开核验范围包括出版方样章、作者节选与采访，详见 [sources.md](references/sources.md)。

[ZaynHao 的公开 UI 实践](https://x.com/ZaynHao)与 Benji Taylor 的 [Honkish](https://benji.org/honkish)用于补充具体表达与操作手感。它们不替代内容和理解判断，个人参数也不被写成通用标准。
