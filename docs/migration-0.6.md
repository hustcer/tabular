# 迁移到 0.6.0

0.6.0 包含源代码和输出兼容性变化，不应作为 0.5.x 补丁版本发布。本版本覆盖的数据变换、通用配置、文本处理、宽高、Padding/Margin 见 [CHANGELOG](../CHANGELOG.md)；[移植对照](tabled-parity.md) 列出的其余功能仍未完成。

## 默认输出

| 行为                                    | 0.5.x                | 0.6.0                       |
| --------------------------------------- | -------------------- | --------------------------- |
| `Table::from_rows` 水平对齐             | 居中                 | 左对齐                      |
| 多行文本对齐                            | 每行独立对齐         | 整块文本对齐（`PerCell`）   |
| 裸 `papergrid.SpannedConfig::default()` | ASCII 边框及左右填充 | 无边框、无填充              |
| 放不下的宽字符占位符                    | `.`                  | `�`                         |
| Unicode / ANSI 宽度                     | 近似范围、部分处理   | 上游 Unicode 17 / ANSI 规则 |

需要原来的居中、逐行对齐方式时，显式设置：

```moonbit
let table = @tabular.Table::from_rows([["long\nx", "value"]])
  .with_(@tabular.Alignment::center())
  .with_(@tabular.AlignmentStrategy::PerLine)
table.set_width(@tabular.Width::wrap_with(10, ".")) |> ignore
```

直接使用 `papergrid` 时，可调用 `set_borders(Borders::ascii())`、`set_padding(1, 1, 0, 0)` 恢复原边框和填充，再按需设置对齐策略。`Table::from_rows` 仍自动设置 ASCII 边框和左右各一格填充。

Unicode、跨行/跨列尺寸和垂直填充修正会改变部分旧快照。应核对输出含义后更新快照；居中设置不会恢复旧算法的错误尺寸。

## Builder 追加记录 API

统一使用已有的 `Builder::push_record(row)`，在末尾追加一条记录：

```moonbit
builder.push_record(["Alice", "30", "NYC"])
```

0.5.x 的 `Builder::extend(row)` 使用了 MoonBit 保留关键字，需迁移到
`push_record(row)`。过渡名称 `Builder::extend_(row)` 仍保留兼容，但已标记为
弃用，调用时会提示改用 `Builder::push_record`。

这两个旧名称都表示追加一条记录，并非批量追加；迁移只需更换方法名，参数和行为不变。

## Width / Height 类型

`Width`、`Height` 现在只作为工厂名称，不能继续作为工厂返回值的类型注解，也不能匹配旧的 `Wrap/Truncate/Increase/Limit` 枚举分支。

| 调用                   | 默认返回类型                  |
| ---------------------- | ----------------------------- |
| `Width::wrap(10)`      | `Wrap[Int, PriorityNone]`     |
| `Width::truncate(10)`  | `Truncate[Int, PriorityNone]` |
| `Width::increase(10)`  | `MinWidth[Int, PriorityNone]` |
| `Width::justify(10)`   | `Justify[Int]`                |
| `Width::list([10, 8])` | `WidthList`                   |
| `Height::increase(3)`  | `CellHeightIncrease[Int]`     |
| `Height::limit(3)`     | `CellHeightLimit[Int]`        |
| `Height::list([3, 2])` | `HeightList`                  |

通常删除原来的 `: Width` / `: Height` 注解，让编译器推断即可。传入 `Max`、`Min`、`Percent` 或调用 `.priority(...)` 会改变对应类型参数；高度选项调用 `.priority(...)` 后返回只用于表级配置的 `TableHeightIncrease` / `TableHeightLimit`。

需要在同一变量或集合中保存旧式渲染模式时，使用 `papergrid.WidthMode` / `papergrid.HeightMode`。它们可以直接传给 `Table::set_width/set_height` 或 `Setting::width/height`。直接构造 `Setting::W/H` 时，其内容也必须换成这些模式类型。

`Padding` 新增四边填充字符；优先通过 `Padding::new/zero/from_sides` 构造，再用 `.fill(...)` 配置，避免依赖具体字段集合。

## 选择正确的配置入口

| 入口                                            | 作用                                         |
| ----------------------------------------------- | -------------------------------------------- |
| `set_width/set_height`、`Setting::width/height` | 保留原渲染时处理方式，不直接修改单元格字符串 |
| `modify(object, Width/Height option)`           | 修改选中单元格的记录内容                     |
| `with_(Width/Height option)`                    | 调整整张表格的尺寸，包含相应边框、填充和边距 |

例如 `modify((0, 0), Width::wrap(2))` 会把 `"abcd"` 改为 `"ab\ncd"`；`with_(Width::wrap(20))` 的 20 是整表目标宽度。最小边框与填充可能使整表无法缩到指定尺寸。

保留单词、调整优先级、后缀限制、百分比等高级能力使用 `with_` / `modify`。旧 setter 的转换只表达旧模式参数，不承载全部高级选项。

## Entity 和自定义配置

`Entity` 现在由公开的 `papergrid` 包拥有，根包继续重导出。原 `Row`、`Col` 可继续使用；新增 `Global`、`Column`、`Cell`，对旧枚举的穷尽匹配需要处理新分支。`Rows::filter` / `Cols::filter` 仍接收同一个重导出的实体类型。

自定义 `TableOption` / `CellOption` 的 `hint_change` 决定维度缓存失效范围。默认全局失效；组合选项按上游规则汇总提示，在选项执行结束后清理缓存。自定义 `Measurement` 使用 `measure(table, Attribute::Width/Height)`，代替 Rust 的泛型属性参数。

## 直接修改记录和配置

`Table::from_rows` 保留输入数组引用，`rows`、`config` 和 `get_dimension_mut()` 是底层可变入口。绕过配置选项直接修改内容、边框或填充后，应调用 `table.get_dimension_mut().clear()`，再执行依赖尺寸的操作。

读取 `to_string/total_width/total_height` 不会填充或改写公共缓存。缓存条目不足当前行列数时会安全重新估算该轴；条目足够时仍被视为显式尺寸，不会自动检查内容是否改变。`get_dimension()` 返回独立副本。

`Width::list` 的多余条目继续保留，但表级 wrap、truncate、increase 只计算和调整实际列。
`CompleteDimension::estimate` 与渲染复用 `papergrid.IterGridDimension::rendered_dimension`，
因此 `total_width/total_height` 也会计入兼容 setter 和 `Setting` 的渲染时宽高处理；
显式宽高列表仍优先。`PeekableGridDimension` 与静态 `IterGridDimension::width/height`
保持原有上游测量规则，直接使用底层 API 时应按需要选择原始记录测量或渲染尺寸测量。

## 发布范围

完整 Theme/Style、Object/Location、其他表格类型、部分底层 API、派生/宏和 workspace 转换器仍在移植中。当前测试数及源测试映射是已覆盖行为的证据，不能解读为整个 `tabled` workspace 已经兼容。
