# 0.6 新增 API 命名调整

范围：`v0.5.2` 之后新增的公开类型、方法、变体、字段和参数。0.6 尚未发布，
因此直接采用下列名称，不再为这些开发期名称新增兼容别名。
此前已明确保留的 `Builder::extend_` 弃用入口继续转发到 `push_record`。
0.5.x 的其他兼容性变化见 [迁移指南](migration-0.6.md)。

## 命名约定

- 类型用完整、表达职责的名称；方法使用 `snake_case`，按实际行为命名。
- 列相关的新入口统一为 `col/cols`，与已有 `Cols`、`Span::col`、`Builder::push_col` 一致。
- 方向、相等值处理规则使用枚举；开关参数统一为 `enabled`。
- 源/目标、四边值、多个布尔配置使用具名参数，避免同类型位置参数传反。
- 尺寸数组使用 `widths/heights`；同时适用于行、列的选择器使用 `sizes/minimums`。
- 区分复制和共享缓存访问；区分使缓存失效和实际测量。
- `with_` 保留作为 `with` 关键字的避让方式。已有 `Table::apply` 专用于 Style，
  不与通用配置入口混用。保留既有 `Padding::new(left, right, top, bottom)` 的位置参数。

## 主要名称对应

| 开发期名称                            | 最终名称 / 调用                               | 含义                                             |
| ------------------------------------- | --------------------------------------------- | ------------------------------------------------ |
| `CompleteDimension::reastimate(hint)` | `invalidate(hint)`                            | 清除受影响轴的缓存；不立即测量                   |
| `Table::get_dimension()`              | `dimension_snapshot()`                        | 独立缓存副本，不触发测量                         |
| `Table::get_dimension_mut()`          | `dimension_cache()`                           | 表格共享的可变缓存                               |
| `Dup::new(dst, src)`                  | `Duplicate::new(source=src, destination=dst)` | 先快照源内容，再写目标                           |
| `Charset`                             | `TextCleanup`                                 | 清理记录中的控制字符或展开 Tab                   |
| `Charset::charset_clean(text)`        | `TextCleanup::clean_text(text)`               | 移除 C0 控制字符（保留换行），Tab 替换成四个空格 |
| `Charset::new().clean()`              | `TextCleanup::new().remove_control_chars()`   | 启用控制字符清理                                 |
| `.tab_size(size)`                     | `.expand_tabs(tab_width)`                     | 每个 Tab 替换为指定数量空格，不按制表位对齐      |
| `Justify`、`Width::justify(width)`    | `UniformWidth`、`Width::uniform(width)`       | 统一所有单元格的文本宽度                         |
| `Justification`                       | `AlignmentFill`                               | 对齐空白使用的填充字符与颜色，不是列宽设置       |
| `Truncate::suffix_try_color(color)`   | `inherit_suffix_style(enabled)`               | 让截断后缀继承文本尾部的 ANSI 样式               |
| `ModifyList`                          | `CellSettings`                                | 对选定对象延迟应用的单元格配置                   |
| `Modify::list(object, option)`        | `Modify::new(object).with_(option)`           | 使用已有组合入口，不保留重复工厂                 |
| `Reverse::columns(start)`             | `Reverse::cols(start)`                        | 反转从该列开始的范围                             |
| `Reverse::limit(Offset::Start(n))`    | `Reverse::take(n)`                            | 从起点反转 n 项，n 不是结束下标                  |
| `Reverse::limit(Offset::End(n))`      | `Reverse::exclude_last(n)`                    | 排除表格末尾的 n 行或列                          |
| `Rotate::Top / Bottom`                | `Reverse::rows(0)`                            | 两个旧变体均为行顺序翻转，统一使用明确的翻转入口 |
| `Padding::expand(true/false)`         | `PaddingExpand::Horizontal / Vertical`        | 用方向枚举替代布尔值                             |
| `Table::count_columns()`              | `count_cols()`                                | 与已有列查询命名一致                             |
| `Span::column(n)`                     | 已有 `Span::col(n)`                           | 合并同义工厂                                     |
| `Entity::Column(n)`                   | 已有 `Entity::Col(n)`                         | 合并同义变体                                     |

`Reverse::take` 和 `exclude_last` 设置的是互斥的范围边界，后一次调用覆盖前一次。
负数、溢出或超出表格的范围仍保持原先的“不修改表格”行为，不自动截短。
`Rotate::Left / Right` 继续表示四分之一圈旋转。

## 调整尺寸的选择器

`Peaker::peak` 改为 `ResizeSelector::select`。参数依次为选择器、最小尺寸数组、
当前尺寸数组；返回待调整的索引，`None` 表示停止。空的最小尺寸数组表示未传入
显式下界。这里的尺寸既可以是列宽，也可以是行高。

| 开发期名称                           | 最终名称                                        |
| ------------------------------------ | ----------------------------------------------- |
| `PriorityNone`、`Priority::none()`   | `PriorityRoundRobin`、`Priority::round_robin()` |
| `PriorityLeft`、`Priority::left()`   | `PriorityFirst`、`Priority::first()`            |
| `PriorityRight`、`Priority::right()` | `PriorityLast`、`Priority::last()`              |
| `PriorityMin::left()`                | `PriorityMin::prefer_last()`                    |
| `PriorityMin::right()`               | `PriorityMin::prefer_first()`                   |
| `PriorityMax::left()`                | `PriorityMax::prefer_first()`                   |
| `PriorityMax::right()`               | `PriorityMax::prefer_last()`                    |

上游 Min 与 Max 对相等值的选择不同，以上映射保留结果，并直接表达最终选中的索引。
`TieBreak::First` 表示相等尺寸中索引最小者，`Last` 表示索引最大者；同样适用于行。

```moonbit
Priority::min(tie_break=TieBreak::First)
Priority::max(tie_break=TieBreak::Last)
PriorityMin::new(tie_break=TieBreak::First)
PriorityMax::new(tie_break=TieBreak::Last)
```

旧 `PriorityMin::new(true)` / `Priority::min(true)` 对应 `First`，`false` 对应 `Last`；
旧 Max 的 `true` 对应 `Last`，`false` 对应 `First`。
`PriorityMin::default()` 仍优先最后一个相等值，`PriorityMax::default()` 仍优先第一个。
默认轮询仍跳过零尺寸，并保留下一次选择的位置；本次不改变参考测试中的调整顺序。

## 颜色和底层尺寸 API

| 开发期名称                                                                       | 最终名称                                                             |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `Color::rgb_fg / rgb_bg`                                                         | `fg_rgb / bg_rgb`，与 `fg_red / bg_red` 一致                         |
| `Color::bitor(other)`                                                            | `combine(other)`；`BitOr` 运算符仍可用                               |
| `Color::try_from(text)`                                                          | `try_parse(text)`，返回 `Result`                                     |
| `Color::parse(text)`                                                             | `parse_or_abort(text)`，名字明确表示失败会终止                       |
| `Color::as_ansi_str()`                                                           | `as_static_ansi()`，仅静态来源的颜色返回 `Some`                      |
| `ANSIBuf::as_ref()`                                                              | `as_ansi_str()`，转换为 ANSI 前后缀对                                |
| `ANSIBuf::try_from(text)`                                                        | `try_parse(text)`                                                    |
| `papergrid.trim_ansi(text)`                                                      | `trim_ansi_whitespace(text)`，去除可见空白并保留 ANSI                |
| `SpannedConfig::get_justification / get_justification_color / set_justification` | `get_alignment_fill / get_alignment_fill_color / set_alignment_fill` |
| `SpannedConfig::get_margin_offset()`                                             | `get_margin_offsets()`，与 `set_margin_offsets` 及四边返回值一致     |
| `IterGridDimension::width / height`                                              | `measure_widths / measure_heights`                                   |
| `IterGridDimension::width_total / height_total`                                  | `total_width / total_height`                                         |
| `IterGridDimension::rendered_dimension`                                          | `measure_rendered`                                                   |
| `PeekableGridDimension::width / height / dimension`                              | `measure_widths / measure_heights / measure`                         |
| `PeekableGridDimension::get_values()`                                            | `dimensions()`                                                       |

静态测量和缓存读取仍是不同操作；`measure_rendered` 计入兼容宽高模式，
`measure_widths/measure_heights` 保留原始记录测量规则。返回尺寸对的顺序仍为
`(widths, heights)`。动态构造或解析的颜色通过 `to_ansi_buf()` 获取样式；
`as_static_ansi()` 不会把动态来源悄悄转换成静态来源。

## 参数与字段

```moonbit
Duplicate::new(source=Rows::one(0), destination=Rows::one(1))
Margin::new(left=1, right=2, top=0, bottom=0)
Padding::new(1, 1, 0, 0).fill(left='>', right='<', top=' ', bottom=' ')
Formatting::new(trim_horizontal=true, trim_vertical=false, align_lines=true)
Wrap::wrap("hello world", 7, keep_words=true)
```

- `Margin::new/fill`、`Padding::fill`、`PaddingColor::new`、`MarginColor::new`、
  `Sides::new` 的四边均为必需具名参数 `left~ / right~ / top~ / bottom~`。
- `Formatting` 字段与构造参数统一为 `trim_horizontal / trim_vertical / align_lines`。
- `Wrap::keep_words`、`Truncate::multiline`、`inherit_suffix_style` 的开关参数为 `enabled`。
  `Wrap::wrap` 的第三个参数改为必需具名参数 `keep_words~`。
- `WidthList`、`HeightList` 的字段和输入参数分别为 `widths / heights`；
  `CompleteDimension` 的数组字段也改为 `widths / heights`。
- `Wrap.words` 改为 `keep_words`；`Truncate.limit / lines / color` 分别改为
  `suffix_limit / multiline / inherit_suffix_style`。
- Height 工厂的 `size` 参数改为 `height`；按列访问的新增尺寸方法统一使用 `col`。

## 复核范围

命名复核覆盖两个包生成的公开接口、对应实现参数、调用点、可执行文档、
测试生成器和从固定 Rust 源码重新生成的夹具。历史审查记录和上游名称保留原貌，
当前迁移指南和 README 使用最终名称。

保留现有表格输出、参考值、源测试名称及原本忽略的测试；新增测试针对明确的
TieBreak 选择以及从非零起点排除末尾项目的范围语义。
未新增对 v0.5.2 已有方法的重命名；开发期 API 的替换关系均列于上表。

### 验证结果（2026-09-08）

- 已复核根包 395 个、papergrid 236 个公开函数/方法声明及对应参数。
  与重命名前比较，没有额外移除或重命名 v0.5.2 已有的方法。
- `moon info`、`moon fmt`、四后端 `moon check/build/test --target all --deny-warn`
  通过；wasm、wasm-gc、JS、native 各 **1331/1331** 项测试通过。
- 在隔离副本中从固定 Rust 源码重新生成变换、宽度、格式、填充/边距测试及五类
  参考夹具，生成结果与工作区一致；该副本的 **1331** 项测试通过。
- Nushell API 名称转换和字面量测试通过，所有项目 Nushell 脚本无 IDE diagnostic。
- README 和两个生成接口不再引用这批旧名称；迁移对照及历史证据中的旧名有明确语境。
  源测试名称、Rust 引用和已有输出期望保持不变。

复核未发现本次范围内仍需修改的命名问题。保留的旧 API 命名差异及 `with_` 的
关键字避让已明确记录，不把这些兼容性约束扩展为新的重复接口。
