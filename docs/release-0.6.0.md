# 0.6.0 发布收尾审计

审查日期：2026-09-08。基线：`282cf500d245abcdc0f9ef38535665b2c7578868`；初审使用 `git diff 282cf50...fa0cd11`，涵盖之后的十组提交，并复核本轮修复。

结论：本阶段变更达到本地发布检查标准，可作为含兼容性变化的 **0.6.0** 进入发布流程。不能把本版本描述为全量 tabled 移植完成。当前仅准备版本和本地归档，未创建发布标签或发布新版本；Windows/Linux/macOS 远端 CI 尚需在提交推送后确认。

后续复核：扩大到 `v0.5.2...95cf77e` 后发现的列宽缓存越界、兼容 setter 尺寸查询
和 Cargo 产物路径三项问题均已修复，Builder 改名文档遗漏也已补齐。最新工作区
四后端各 **1329** 项测试通过，无 Warning，旧测试期望没有修改；详见
[完整审查与修复记录](review-since-v0.5.2.md)。下面保留此前 1322 项测试阶段的审计证据。
受审 HEAD `95cf77e` 的三平台 CI 已通过；新增修复尚未推送，不能将旧 CI 结果视为修复后的结果。

本报告保留该阶段的审计证据；发布前新增 API 的最终命名、参数调整与后续检查见
[API 命名调整](api-naming-0.6.md)。

## Standards：规范与发布维护

| 初审发现                                                             | 处理结果                                                                                              |
| -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| P1：公开记录数组增长或显式短维度缓存导致切片越界                     | 已复现，过短缓存按当前形状重新估算；完整缓存和读取不改缓存的语义保留，新增 3 个回归测试               |
| P2：具名 Width/Height 类型和默认行为变化缺少迁移说明，版本仍为 0.5.2 | 已准备 0.6.0，补齐 CHANGELOG 和 [迁移文档](migration-0.6.md)，包含模式转换、Entity 分支及底层缓存契约 |
| P2：README Spans 输出与代码不一致，Gallery 未说明居中                | 修正 Span 输出并补显式居中；Quick Start 和 Spans 均改为可执行断言，Gallery 标明当前实现范围           |

三项均已处理。未发现需要阻碍本次发布的代码结构问题。额外将 CI 扩展至 PR 和 Markdown 变更，加入格式、生成接口一致性检查，并让检查、构建、测试拒绝 Warning。

## Spec：需求符合性

初审发现一项本轮能力组合的实现错误：无边框表格上下 Margin 用字符串长度计算宽度，中文“中”应填 4 格却填 3 格；红色 ANSI `x` 应填 3 格却填 13 格。已通过 Rust 复现，并改为列宽之和加边框数量，新增覆盖两种输入的回归测试。

另有 70 组独立 Rust/MoonBit 逐字差分通过，覆盖空文本、多行、CJK、ANSI、CR、Tab 与 Trim、Alignment、Color、Padding、Justification/Height 的组合。两个 Rust 自身会 panic 的额外输入未计入这 70 组；没有删除任何上游原始测试。

完整目标仍有未完成项：源清单中 1,387 个命名测试候选只有 278 个显式映射，且清单不包含文档测试及匿名宏展开。完整 Style/Theme、Object/Location、其他表格类型、剩余 papergrid API、派生/宏、workspace 转换器均应继续跟踪；已确认的基线预设差异记录在 [移植对照](tabled-parity.md)。这些是原全量目标的缺口，不应在本次阶段版本说明中隐去。

## 可重复验证

本地工具链：`moon 0.1.20260827`、`moonc v0.10.11+6ff76a5f9`、`rustc 1.98.1`、`Nushell 0.115.1`。本机为 macOS；四后端结果不能替代 Windows/Linux 操作系统验证。

```sh
moon info
moon fmt
moon fmt --check
moon check --target all --deny-warn
moon build --target all --deny-warn
moon test --target all --deny-warn
git diff --check
moon package
```

- wasm、wasm-gc、JS、native 各 1322 项运行测试通过；另有 1 项保留上游原有忽略原因的测试。
- 本轮没有改变公开 `.mbti` 接口；基线之后的接口变化已逐项检查并写入迁移文档。
- 五类 Rust 探针的传递依赖已锁定；全部重新生成后的测试期望没有变化，六个相关 Nushell 脚本无 IDE diagnostic。
- 本地归档包含模块清单、公开接口、源码、测试、README、迁移文档、LICENSE、THIRD_PARTY_NOTICES 和探针锁文件；未夹带构建目录或本地任务记录。
- 归档在新建临时目录解压后独立完成 `moon check --deny-warn` 和全部 1322 项默认后端测试，不依赖工作区或 Rust 上游源码。

归档检查使用 `moon package`；该命令及文件清单检查方式见 [MoonBit 官方模块文档](https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html)。此前以 0.5.2 执行的 `moon publish --dry-run` 返回重复版本 409，未完成发布；后续使用本地打包验证，没有再次调用发布接口。

本次收尾发现：Standards 3 项，已处理 3 项；Spec 当前实现错误 1 项，已处理 1 项。原全量移植目标仍未完成，0.6.0 的发布范围以 CHANGELOG 和移植对照为准。
