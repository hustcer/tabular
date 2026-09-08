# tabled 移植对照

参考源码：`tabled` commit `6f40434650aa0c8a27ecb243d42af605b4206b73`。

当前尚未完成全量对齐。测试通过只说明当前覆盖的行为通过，不能证明整个 tabled workspace 已移植。

## 本次完成的数据变换

| 上游                                         | MoonBit API                                 | 原始测试保留情况                                        |
| -------------------------------------------- | ------------------------------------------- | ------------------------------------------------------- |
| `Rotate::{Left,Right,Top,Bottom}`            | `Table::rotate(Rotate)`                     | `rotate_test.rs` 全部 12 例，含恒等式与保留边框配置     |
| `Reverse::{rows,columns}.limit(Offset)`      | `Table::reverse(Reverse)`                   | `reverse_test.rs` 全部 12 例，另保留源码内 2 个单元测试 |
| `Concat::{horizontal,vertical}.default_cell` | `Table::concat(Concat)`                     | `concat_test.rs` 全部 8 例                              |
| `Dup::new(dst,src)`                          | `Table::duplicate(Dup)`                     | `duplicate_test.rs` 全部 14 例                          |
| `Object`                                     | `Object` trait，Rows/Cols/Cell/Segment 实现 | 保留实体分组顺序，支持自定义对象与无效坐标过滤          |

以上 48 个原始测试全部保留测试名称、源路径及预期语义。其中 45 个 `test_table!` 快照由 `scripts/import-transform-tests.nu` 从源码提取，另外 3 个普通测试在 `transform_test.mbt` 中移植。另有 9 个额外边界测试和 4 个可执行 API 文档示例。

重新生成快照测试：

```sh
nu --no-config-file scripts/import-transform-tests.nu /path/to/tabled
moon fmt
moon test --filter 'upstream*'
```

生成器不会读取 MoonBit 实际输出来制造预期结果，也不会静默跳过无法识别的 `test_table!`。它只写入带有自身生成标记的目标文件。

[`upstream-test-inventory.json`](upstream-test-inventory.json) 当前列出 90 个源文件中的 1,387 个命名测试候选，278 个带有明确的 MoonBit 源引用。它包括条件编译测试，以及 MoonBit 黑盒和白盒测试的源引用，但不包括文档测试和未展开的匿名宏测试；既有测试缺少源引用也会标为未映射。重新生成清单：

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
- 新增保留样式的截断/换行与 OSC8 单链接重建；32 组输入在 7 种宽度下比较 Rust 的截断、普通换行和保留单词换行，共 672 项断言。
- 默认宽字符占位符改为上游的 `�`。旧点号测试通过显式 `wrap_with(1, ".")` 保留原预期；原测试字面量没有修改。

参考值直接由本地上游 Rust 生成，独立于 MoonBit 输出。重新生成两组差分夹具（需要 Cargo）：

```sh
nu --no-config-file scripts/import-ansi-reference-tests.nu /path/to/tabled
moon fmt
moon test
```

ANSI、尺寸、宽度、高度、填充/边距的五类编译探针统一使用 `scripts/upstream-probe.nu`：要求上述固定上游提交及干净的 tabled/papergrid 源码，并通过 `scripts/reference/Cargo.lock` 和 `cargo build --locked` 锁定传递依赖。2026-09-08 重新生成全部五类夹具后，格式化结果与提交中的期望值逐字一致。显式 `--probe` 用于调试，调用者自行负责该外部二进制的来源。

探针构建显式将产物放入自身临时目录，并读取 Cargo JSON 中的实际可执行文件路径，
避免 `CARGO_TARGET_DIR` 或显式主机目标导致路径错误。可运行以下集成验证（需要 Cargo）：

```sh
nu --no-config-file scripts/upstream-probe_test.nu /path/to/tabled
```

以上差分夹具是额外验证，不计入原始命名测试映射。原始宽度测试的覆盖范围见下节；其他渲染器和 ANSI 配置仍需继续核对。

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

## 高级宽度选项与尺寸缓存

- `Width` 改为选项工厂，返回 `Wrap`、`Truncate`、`MinWidth`、`Justify`、`WidthList`；支持通用测量和优先级。单元格选项直接修改记录，表级选项调整包含填充、边框、边距的总宽度。
- 保留单词换行、截断后缀的 `Cut/Ignore/Replace`、逐行截断、后缀取色、单元格最小宽度填充、统一宽度、列宽列表均已接入。
- `CompleteDimension` 保留缓存失效和显式列表优先规则，并与渲染共享处理后尺寸测量；`PeekableGridDimension` 保留上游原始记录测量语义。`with_` 在组合选项全部完成后按合并的 hint 清理缓存，读取渲染结果不会填入公共缓存。
- 多余列宽条目继续保留，表级 wrap、truncate、increase 的总宽计算和优先级选择仅作用于实际列；兼容 setter 和 `Setting` 的渲染时宽高处理计入 `total_width/total_height`。
- 保留 `width_test.rs` 全部 122 个 `test_table!` 和 7 个普通测试函数，包括原始 ANSI/OSC 期望值和额外宽度断言。普通测试的派生字段在测试辅助代码中显式表示；语言派生功能仍待实现。
- 保留 `wrap.rs` 全部 18 个源码测试函数，其中 2 个早先已移植，新增剩余 16 个；包含前后缀、多样式文本、中文和宽字符边界。
- 25 组 Rust 差分场景同时核对内容、输出、缓存、总宽高，覆盖元组与数组、百分比、测量、优先级、跨行、CRLF、列宽列表和显式行高。
- 修正跨列宽度按跨度顺序分摊，以及跨行单元格的垂直填充计算。10 个既有快照场景使用 `scripts/reference/span_probe.rs` 的相同 Rust 输入核对后更新；保留测试场景，没有沿用旧算法的错误输出。
- 新增基础 `Margin::new/fill` 和 `Padding::zero`。旧 `set_width` / `Setting::width` 保留渲染时处理的兼容入口；高级选项使用 `with_` / `modify`。

```sh
nu --no-config-file scripts/import-width-tests.nu /path/to/tabled
nu --no-config-file scripts/import-wrap-tests.nu /path/to/tabled
nu --no-config-file scripts/import-width-state-tests.nu /path/to/tabled
moon info
moon fmt
moon test
```

## 高度选项

- `Height` 改为工厂，返回 `CellHeightIncrease`、`CellHeightLimit`、`TableHeightIncrease`、`TableHeightLimit` 和 `HeightList`；接入通用测量和调整优先级。
- 单元格增加高度会追加换行，截短会保留 ANSI 样式；整表高度从记录重新测量，包含边框与上下边距，并保留上游对已有缓存的处理。
- 保留 `height_test.rs` 全部 14 个原始测试及期望文字；其中两个嵌套宏案例按原宏展开成表格构造，宏等价 API 仍在待办范围。
- 37 组 Rust 差分场景同时核对文本、输出、缓存和总宽高，覆盖测量、优先级、填充、边距、跨度、ANSI/CRLF、组合选项和重复调整。
- 修正 `total_height()` 只累计实际行数，额外的列表项继续保存在缓存中；保留旧 `set_height` / `Setting::height` 渲染时处理入口。

```sh
nu --no-config-file scripts/import-height-tests.nu /path/to/tabled
nu --no-config-file scripts/import-height-state-tests.nu /path/to/tabled
moon info
moon fmt
moon test
```

## Padding、Margin 与四边配置

- 补齐 `Padding::fill/expand/from_sides/to_sides`、`PaddingExpand`、`PaddingColor`、`MarginColor`，以及 `Margin` 与四边配置的转换。颜色接受实现 `ANSIFmt` 的值，包括 `Color`、`ANSIBuf` 和 `ANSIStr`。
- `papergrid` 新增 `Sides`、`Indent`、填充与边距颜色查询/设置、带方向的边距偏移；`Offset` 移至 `papergrid` 并由根包重导出。坐标重映射保留填充字符与颜色配置。
- 保留 `padding_test.rs` 全部 7 例和 `margin_test.rs` 全部 8 例。其中 `table_0_spanned_with_width` 在上游已经忽略，MoonBit 以 `#skip` 保留其原始原因、两条断言和类型检查；其余 14 例全部运行。
- 保留底层 `settings.rs` 的 4 个 Padding 行/列覆盖案例，以及 5 个包含断言的上游文档示例。
- 32 组 Rust 差分场景比较输出、原始记录、缓存、总尺寸和实际 Padding 数值；包含扩展、对齐、跨度、颜色清除、零填充、作用域覆盖、边距偏移和缓存交互。
- 修正垂直对齐只从可用高度扣除顶部 Padding 的上游规则，保持底部 Padding 对居中/底对齐位置的影响；没有修改既有测试期望。

```sh
nu --no-config-file scripts/import-indent-tests.nu /path/to/tabled
nu --no-config-file scripts/import-indent-doc-tests.nu /path/to/tabled
nu --no-config-file scripts/import-indent-state-tests.nu /path/to/tabled
moon info
moon fmt
moon test
```

| 范围                                     | 当前证据 / 待办                                                                                                                 |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Builder / IndexBuilder                   | 已有实现和部分测试，需逐个核对方法、泛型数据入口、异常边界                                                                      |
| Table 核心 API                           | 已补齐 TableOption / CellOption / Settings / Modify、统一 Alignment 和尺寸查询；Tabled 数据模型和其他查询接口仍需核对           |
| 格式                                     | 已保留全部 render_settings 组合案例；继续核对更多 Span/Width/Height 组合与其他渲染器                                            |
| 宽高                                     | 已接入高级 Width/Height 并保留 width_test.rs/height_test.rs/wrap.rs 全部测试；其他渲染器的宽高语义仍需补齐                      |
| Padding / Margin                         | Table / SpannedConfig 的填充、扩展、四边颜色、偏移已接入并保留对应源测试；其他渲染器仍待实现                                    |
| 颜色 / ANSI                              | 已补齐样式解析、Unicode 文本测量、修剪、裁剪/换行及填充/边距颜色；仍缺边框颜色、Colorization 与剩余 ANSI 边界                   |
| Style / Theme                            | 缺少完整 VerticalLine、LineChar、LineText、Theme、Layout、ColumnNames/RowNames 等；基线已有的 rounded/blank/dots 预设差异见下文 |
| Object / Location                        | 已有部分对象集合，仍需 Frame、完整组合顺序/迭代器及 ByContent/ByCondition/ByValue                                               |
| Span / Panel / Merge / Highlight / Split | 已有实现，尚需上游全部原始测试的逐项映射与行为审计                                                                              |
| 其他表格                                 | 缺少 IterTable、CompactTable、ExtendedTable、PoolTable 及其配置和测试                                                           |
| papergrid                                | 当前 IterGrid/SpannedConfig 为部分实现，需核对全部渲染器、Records、Dimension、底层配置/ANSI/Unicode 与原始测试                  |
| 派生 / 宏                                | tabled_derive、static_table、row/col 宏需提供 MoonBit 等价能力并保留可运行测试语义                                              |
| workspace 转换器                         | json/csv/ron/toml/html 等转换器尚未移植，不能视为已覆盖                                                                         |
| 全量测试                                 | 未映射的旧测试需逐项核对；源测试清单只作为定位工具，不作为语义一致的证明                                                        |

## 当前验证

发布收尾审查还确认了三项在 `282cf50` 基线前已存在的预设差异：`rounded` 当前对每行加分隔线，上游只分隔表头；`blank` 当前与 `empty` 等同，上游多一个空格列分隔；`dots` 当前顶底线形式与上游不同。这些属于后续 Style 对齐范围，README Gallery 展示的是当前 MoonBit 行为。

2026-09-08：`moon info`、`moon fmt` 以及全部四个后端的 `moon check/build/test --target all --deny-warn` 均成功，1322/1322 个运行测试分别通过，另保留上游原本忽略的 1 例，无 Warning。收尾新增缓存边界与无边框 ANSI/CJK Margin 的 4 个回归测试，以及 2 个可执行 README 示例；详见 [0.6.0 发布审计](release-0.6.0.md)。此结果对应已完成的数据变换、通用配置、当前格式、ANSI/Unicode 文本、尺寸测量、高级宽高和当前填充/边距能力，不表示上表的未完成项目已对齐。

同日后续复核：扩大到 v0.5.2 基线后的新发现均已修复。新增 Builder 文档测试、5 个
列宽/兼容尺寸回归测试和 1 个渲染尺寸 API 文档测试，四后端各 **1329/1329** 项通过，
无 Warning；未修改旧快照或 Rust 参考期望。Cargo 探针在自定义输出目录和显式主机
目标下均能构建并运行。完整证据见 [v0.5.2 后审查与修复](review-since-v0.5.2.md)。
