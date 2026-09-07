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

[`upstream-test-inventory.json`](upstream-test-inventory.json) 当前列出 90 个源文件中的 1,387 个命名测试候选，48 个带有明确的 MoonBit 源引用。它包括条件编译测试，但不包括文档测试和未展开的匿名宏测试；既有测试缺少源引用也会标为未映射。重新生成清单：

```sh
nu --no-config-file scripts/audit-upstream-tests.nu /path/to/tabled --output docs/upstream-test-inventory.json
```

### 容易混淆的上游行为

- `Top` 和 `Bottom` 都只翻转行顺序。旋转与翻转后，配置仍然属于原来的表格坐标。
- `Dup` 先收集源值，避免源目标重叠导致覆盖；每个目标行/列独立循环源值。`Segment::all()` 是一个整体实体，矩形 `Segment::new(...)` 则逐单元格处理。
- `Concat` 保留第一个表格配置。自定义默认内容只填水平拼接新增行、或垂直拼接新增列；另一侧较小时留下的其他缺口使用空字符串。
- MoonBit 接口额外防护负数、溢出长度和自定义对象中的越界坐标。

## 仍需完成的功能与验证

| 范围 | 当前证据 / 待办 |
| --- | --- |
| Builder / IndexBuilder | 已有实现和部分测试，需逐个核对方法、泛型数据入口、异常边界 |
| Table 核心 API | 缺少通用 TableOption / CellOption / Settings / Modify、Tabled 数据模型和完整查询接口 |
| 格式 | 缺少 AlignmentStrategy、TrimStrategy、Justification、Charset；现有默认对齐也需要和上游默认值逐项核对 |
| 宽高 | 现有 Wrap/Truncate/Increase/Limit 只是部分能力，需核对表级与单元格级语义、测量、优先级、列表、最小宽度 |
| Padding / Margin | 需补齐填充字符、PaddingExpand、Margin 及相关偏移和颜色 |
| 颜色 / ANSI | 缺少 Color、边框/填充/边距颜色、Colorization 和完整 ANSI 宽度处理 |
| Style / Theme | 缺少完整 VerticalLine、LineChar、LineText、Theme、Layout、ColumnNames/RowNames 等 |
| Object / Location | 已有部分对象集合，仍需 Frame、完整组合顺序/迭代器及 ByContent/ByCondition/ByValue |
| Span / Panel / Merge / Highlight / Split | 已有实现，尚需上游全部原始测试的逐项映射与行为审计 |
| 其他表格 | 缺少 IterTable、CompactTable、ExtendedTable、PoolTable 及其配置和测试 |
| papergrid | 当前 IterGrid/SpannedConfig 为部分实现，需核对全部渲染器、Records、Dimension、底层配置/ANSI/Unicode 与原始测试 |
| 派生 / 宏 | tabled_derive、static_table、row/col 宏需提供 MoonBit 等价能力并保留可运行测试语义 |
| workspace 转换器 | json/csv/ron/toml/html 等转换器尚未移植，不能视为已覆盖 |
| 全量测试 | 未映射的旧测试需逐项核对；源测试清单只作为定位工具，不作为语义一致的证明 |

## 当前验证

2026-09-08：`moon info`、`moon fmt`、`moon check`、`moon build`、`moon test` 均成功，379/379 测试通过，无 Warning。此结果对应本次数据变换补全，不表示上表的未完成项目已对齐。
