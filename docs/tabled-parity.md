# tabled 移植对照

参考源码：`tabled` commit `6f40434650aa0c8a27ecb243d42af605b4206b73`。

当前尚未完成全量对齐。测试通过只说明当前覆盖的行为通过，不能证明整个 tabled workspace 已移植。

## 本次完成的数据变换

| 上游 | MoonBit API | 原始测试保留情况 |
| --- | --- | --- |
| `Rotate::{Left,Right,Top,Bottom}` | `Table::rotate(Rotate)` | `rotate_test.rs` 全部 12 例，含恒等式与保留边框配置 |
| `Reverse::{rows,columns}.limit(Offset)` | `Table::reverse(Reverse)` | `reverse_test.rs` 全部 12 例，另保留源码内 2 个单元测试 |
| `Concat::{horizontal,vertical}.default_cell` | `Table::concat(Concat)` | `concat_test.rs` 全部 8 例 |
| `Dup::new(dst,src)` | `Table::duplicate(Dup)` | `duplicate_test.rs` 全部 14 例 |
| `Object` | `Object` trait，Rows/Cols/Cell/Segment 实现 | 保留实体分组顺序，支持自定义对象与无效坐标过滤 |

以上 48 个原始测试全部保留测试名称、源路径及预期语义。其中 45 个 `test_table!` 快照由 `scripts/import-transform-tests.nu` 从源码提取，另外 3 个普通测试在 `transform_test.mbt` 中移植。另有 9 个额外边界测试和 4 个可执行 API 文档示例。

重新生成快照测试：

```sh
nu --no-config-file scripts/import-transform-tests.nu /path/to/tabled
moon fmt
moon test --filter 'upstream*'
```

生成器不会读取 MoonBit 实际输出来制造预期结果，也不会静默跳过无法识别的 `test_table!`。它只写入带有自身生成标记的目标文件。

[`upstream-test-inventory.json`](upstream-test-inventory.json) 当前列出 90 个源文件中的 1,387 个命名测试候选，100 个带有明确的 MoonBit 源引用。它包括条件编译测试，以及 MoonBit 黑盒和白盒测试的源引用，但不包括文档测试和未展开的匿名宏测试；既有测试缺少源引用也会标为未映射。重新生成清单：

```sh
nu --no-config-file scripts/audit-upstream-tests.nu /path/to/tabled --output docs/upstream-test-inventory.json
```

### 容易混淆的上游行为

- `Top` 和 `Bottom` 都只翻转行顺序。旋转与翻转后，配置仍然属于原来的表格坐标。
- `Dup` 先收集源值，避免源目标重叠导致覆盖；每个目标行/列独立循环源值。`Segment::all()` 是一个整体实体，矩形 `Segment::new(...)` 则逐单元格处理。
- `Concat` 保留第一个表格配置。自定义默认内容只填水平拼接新增行、或垂直拼接新增列；另一侧较小时留下的其他缺口使用空字符串。
- MoonBit 接口额外防护负数、溢出长度和自定义对象中的越界坐标。

## 仍需完成的功能与验证

本轮还补齐了通用配置接口和以下格式能力：

- `TableOption`、`CellOption`、`Settings`、`Modify`，支持元组、数组、自定义选项和基于内容的列选择；保留上游执行顺序与 `hint_change` 差异。
- `Alignment`、`AlignmentStrategy`、`TrimStrategy`、`Justification`、`Charset`；基础 `Color` 构造、组合、逐行着色和单元格颜色配置。
- `Table` 默认左对齐，`papergrid` 默认无边框/无填充；多行文本默认 `PerCell`。既有居中/逐行对齐测试改为显式配置，保留原来的预期文字。
- 保留 `alignment_test.rs` 的 9 例、`formatting_test.rs` 的 7 例、`color_test.rs` 的 2 例与颜色组合的源码测试。
- 保留 `papergrid/tests/grid/format_configuration.rs` 全部 4 个测试函数的场景，展开为 33 个用例（27 组组合、4 个单格案例、空尺寸循环、Tab 场景）。

格式测试也由 `import-transform-tests.nu` 生成；底层格式测试和转义字面量验证使用：

```sh
nu --no-config-file scripts/import-grid-format-tests.nu /path/to/tabled
nu --no-config-file scripts/upstream-literals_test.nu
```

## ANSI 文本与组合渲染

- 保留 `render_settings.rs` 全部 12 例，包含多行文本、Tab、Span、内嵌颜色及两种对齐策略。
- 补齐 `Color::try_from/parse/from_ansi_str`、`ANSIBuf/ANSIStr` 转换与 `ANSIFmt`；保留 Color 源码内剩余 4 个测试函数和 papergrid 文本工具的 6 个测试函数。
- ANSI 扫描、SGR 状态及重置顺序对照上游依赖 `ansitok 0.3.0`、`ansi-str 0.9.0`；166 组输入逐项验证测量、去序列、修剪、分行与样式解析，共 830 项断言。
- 新增保留样式的截断/换行与 OSC8 单链接重建；21 组输入在 7 种宽度下比较 Rust 的截断和换行结果，共 294 项断言。
- 默认宽字符占位符改为上游的 `�`。旧点号测试通过显式 `wrap_with(1, ".")` 保留原预期；原测试字面量没有修改。

参考值直接由本地上游 Rust 生成，独立于 MoonBit 输出。重新生成两组差分夹具（需要 Cargo）：

```sh
nu --no-config-file scripts/import-ansi-reference-tests.nu /path/to/tabled
moon fmt
moon test
```

以上差分夹具是额外验证，不计入原始命名测试映射。保留单词的换行、完整截断策略及更多 ANSI 边界尚待核对；不能视为整个 ANSI/宽度子系统已完成。

## Unicode 宽度与文本工具

- 替换近似字符范围，移植上游 `unicode-width 0.2.2` 的 Unicode 17.0.0 数据及默认窄歧义字符状态机，覆盖 emoji、变体选择符、ZWJ、肤色修饰符、旗帜和语言连字。
- 883 个压缩元数据区间从 Rust 源码导出；全部 1,112,064 个有效 Unicode 标量的字符宽度和单字符字符串宽度分别通过独立 Rust 摘要核对。
- 5,427 条文本参考输入包含依赖测试中的字符串字面量及完整 emoji 测试数据；合并为 55 个测试组，所有预期由 Rust 计算。
- 保留 `tabled/src/util/string.rs` 全部 4 个测试函数、普通换行的 `split_test/chunks_test`；补齐 `papergrid` 文本工具第 7 个 `replace_tab_test`，包括上游四空格快路径与其他 Tab 宽度的差异。
- 修正 `get_text_width` 对 CRLF 的处理；`get_text_dimension` 继续保留尾部空行和上游不同的 CR 语义。

```sh
nu --no-config-file scripts/import-unicode-width.nu /path/to/unicode-width-0.2.2
nu --no-config-file scripts/import-string-tests.nu /path/to/tabled
moon fmt
moon test
```

Unicode 参考输入属于额外验证，不计入 tabled 的原始测试映射。未提供上游 tabled 没有使用的 `width_cjk` 扩展策略。

## 尺寸测量与调整优先级

- 新增 `Measurement`、`Max`、`Min`、`Percent`。MoonBit trait 不接受类型参数，使用 `Attribute::Width/Height` 参数代替 Rust 的 `Measurement<Width/Height>`。
- 新增 `Peaker`、`Priority` 和五种优先级实现；保留循环选择、左右选择以及最小/最大值平局时不同的上游顺序。
- 新增边框存在性/数量查询和静态行列尺寸测量。百分比测量不包含外边距；跨行/跨列测量分别使用上游对应轴的规则。
- 35 组连续 30 次的优先级调用、40 组尺寸测量场景均由 Rust 产生参考值，覆盖空表、ANSI、CRLF、跨度、不同填充、样式及外边距。

```sh
nu --no-config-file scripts/import-dimension-reference-tests.nu /path/to/tabled
moon fmt
moon test
```

这些基础接口已经独立验证；现有 `Width` 的整表总宽度调整和新选项类型仍待接入，不能将此步骤视为高级宽度功能完成。

| 范围 | 当前证据 / 待办 |
| --- | --- |
| Builder / IndexBuilder | 已有实现和部分测试，需逐个核对方法、泛型数据入口、异常边界 |
| Table 核心 API | 已补齐 TableOption / CellOption / Settings / Modify、统一 Alignment 和尺寸查询；Tabled 数据模型和其他查询接口仍需核对 |
| 格式 | 已保留全部 render_settings 组合案例；继续核对更多 Span/Width/Height 组合与其他渲染器 |
| 宽高 | 测量与 Peaker 基础接口已验证；仍需接入表级与单元格级语义、保留单词换行、完整截断策略、列表、最小宽度及高度高级选项 |
| Padding / Margin | 需补齐填充字符、PaddingExpand、Margin 及相关偏移和颜色 |
| 颜色 / ANSI | 已补齐样式解析、Unicode 文本测量、修剪及基本裁剪/换行；仍缺边框/填充/边距颜色、Colorization 与剩余 ANSI 边界 |
| Style / Theme | 缺少完整 VerticalLine、LineChar、LineText、Theme、Layout、ColumnNames/RowNames 等 |
| Object / Location | 已有部分对象集合，仍需 Frame、完整组合顺序/迭代器及 ByContent/ByCondition/ByValue |
| Span / Panel / Merge / Highlight / Split | 已有实现，尚需上游全部原始测试的逐项映射与行为审计 |
| 其他表格 | 缺少 IterTable、CompactTable、ExtendedTable、PoolTable 及其配置和测试 |
| papergrid | 当前 IterGrid/SpannedConfig 为部分实现，需核对全部渲染器、Records、Dimension、底层配置/ANSI/Unicode 与原始测试 |
| 派生 / 宏 | tabled_derive、static_table、row/col 宏需提供 MoonBit 等价能力并保留可运行测试语义 |
| workspace 转换器 | json/csv/ron/toml/html 等转换器尚未移植，不能视为已覆盖 |
| 全量测试 | 未映射的旧测试需逐项核对；源测试清单只作为定位工具，不作为语义一致的证明 |

## 当前验证

2026-09-08：`moon info`、`moon fmt`、`moon check`、`moon build`、`moon test` 均成功，941/941 测试通过，无 Warning。此结果对应已完成的数据变换、通用配置、当前格式、ANSI/Unicode 文本及尺寸测量基础能力，不表示上表的未完成项目已对齐。
