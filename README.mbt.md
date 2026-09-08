# Tabular

A MoonBit library for pretty-printing tables in the terminal. Inspired by the Rust [tabled](https://github.com/zhiburt/tabled) project.

## Features

- 11 built-in style presets
- Customizable borders and horizontal lines
- Alignment, padding, width, height, and formatting controls
- Row, column, cell, and segment based table editing
- Column span and row span
- Panel, merge, highlight, shadow, split, extract, remove, and border correction
- Builder helpers with index and transpose support
- Rotate, reverse, concatenate, and duplicate selected records
- ANSI text colors, style parsing, and color-preserving width operations

See [tabled parity status](docs/tabled-parity.md) for the upstream test mapping and remaining work.

## Installation

```bash
moon add hustcer/tabular
```

## Quick Start

```moonbit nocheck
let table = @tabular.Table::from_rows([
  ["Name", "Language", "Stars"],
  ["Deno", "Rust/TS", "101k"],
  ["Bun", "Zig/C++", "76k"],
  ["Node.js", "C++/JS", "110k"],
])

table.apply(@tabular.Style::modern()) |> ignore
table.with_(@tabular.Alignment::center()) |> ignore
println(table.to_string())
```

Output:

```
┌─────────┬──────────┬───────┐
│  Name   │ Language │ Stars │
├─────────┼──────────┼───────┤
│  Deno   │ Rust/TS  │ 101k  │
├─────────┼──────────┼───────┤
│   Bun   │ Zig/C++  │  76k  │
├─────────┼──────────┼───────┤
│ Node.js │  C++/JS  │ 110k  │
└─────────┴──────────┴───────┘
```

## Style Presets

```moonbit nocheck
table.apply(@tabular.Style::ascii()) |> ignore
table.apply(@tabular.Style::modern()) |> ignore
table.apply(@tabular.Style::rounded()) |> ignore
table.apply(@tabular.Style::extended()) |> ignore
table.apply(@tabular.Style::dots()) |> ignore
table.apply(@tabular.Style::empty()) |> ignore
table.apply(@tabular.Style::blank()) |> ignore
table.apply(@tabular.Style::re_structured_text()) |> ignore
table.apply(@tabular.Style::ascii_rounded()) |> ignore
table.apply(@tabular.Style::markdown()) |> ignore
table.apply(@tabular.Style::psql()) |> ignore
```

### Gallery

**ascii**

```
+----------+------+
| language | year |
+----------+------+
|   Rust   | 2010 |
+----------+------+
| MoonBit  | 2022 |
+----------+------+
```

**modern**

```
┌──────────┬──────┐
│ language │ year │
├──────────┼──────┤
│   Rust   │ 2010 │
├──────────┼──────┤
│ MoonBit  │ 2022 │
└──────────┴──────┘
```

**rounded**

```
╭──────────┬──────╮
│ language │ year │
├──────────┼──────┤
│   Rust   │ 2010 │
├──────────┼──────┤
│ MoonBit  │ 2022 │
╰──────────┴──────╯
```

**markdown**

```
| language | year |
|----------|------|
|   Rust   | 2010 |
| MoonBit  | 2022 |
```

**psql**

```
 language | year
----------+------
   Rust   | 2010
 MoonBit  | 2022
```

**dots**

```
:.................:
: language : year :
:..........:......:
:   Rust   : 2010 :
:..........:......:
: MoonBit  : 2022 :
:.................:
```

**extended**

```
╔══════════╦══════╗
║ language ║ year ║
╠══════════╬══════╣
║   Rust   ║ 2010 ║
╠══════════╬══════╣
║ MoonBit  ║ 2022 ║
╚══════════╩══════╝
```

**empty / blank**

```
 language  year
   Rust    2010
 MoonBit   2022
```

**re_structured_text**

```
========== ======
 language   year
========== ======
   Rust     2010
 MoonBit    2022
========== ======
```

**ascii_rounded**

```
.-----------------.
| language | year |
|   Rust   | 2010 |
| MoonBit  | 2022 |
'-----------------'
```

## Custom Style

```moonbit nocheck
let style = @tabular.Style::ascii()
  .top('─')
  .bottom('─')
  .left('│')
  .right('│')
  .horizontal('─')
  .vertical('│')
  .corner_top_left('┌')
  .corner_top_right('┐')
  .corner_bottom_left('└')
  .corner_bottom_right('┘')

table.apply(style) |> ignore
```

```moonbit nocheck
let style = @tabular.Style::ascii()
  .remove_horizontal()
  .horizontals([
    (1, @tabular.HorizontalLine::full('-', '+', '+', '+')),
  ])

table.apply(style) |> ignore
```

## Builder

```moonbit nocheck
let builder = @tabular.Builder::default()
builder.push_record(["Name", "Age", "City"])
builder.push_record(["Alice", "30", "NYC"])
builder.push_record(["Bob", "25", "LA"])

let table = builder.build()
println(table.to_string())
```

```moonbit nocheck
///|
let builder = @tabular.Builder::from_rows([
  ["Name", "Age"],
  ["Alice", "30"],
  ["Bob", "25"],
])

///|
let table1 = builder.index().build()

///|
let table2 = builder.index().transpose().build()

///|
let table3 = builder.index().hide().build()
```

## Common Edits

```moonbit nocheck
table.set_align(@tabular.Align::right()) |> ignore
table.set_padding(@tabular.Padding::new(1, 1, 0, 0)) |> ignore
table.set_width(@tabular.Width::wrap(10)) |> ignore
table.set_height(@tabular.Height::increase(2)) |> ignore
```

```moonbit nocheck
table.modify_rows(
  @tabular.Rows::first(),
  @tabular.Setting::align(@tabular.Align::center()),
) |> ignore

table.modify_cols(
  @tabular.Cols::one(1),
  @tabular.Setting::width(@tabular.Width::wrap(8)),
) |> ignore

table.modify_cell(
  @tabular.Cell::new(1, 2),
  @tabular.Setting::format(@tabular.Format::surround("[", "]")),
) |> ignore
```

## Spans

```moonbit nocheck
let table = @tabular.Table::from_rows([
  ["Team", "Q1", "Q2", "Q3"],
  ["A", "12", "18", "22"],
  ["B", "10", "16", "21"],
])

table.apply(@tabular.Style::modern()) |> ignore
table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::col(2)) |> ignore
table.correct_borders() |> ignore
println(table.to_string())
```

Possible output:

```
┌─────────────┬────┬────┐
│    Team     │ Q2 │ Q3 │
├──────┬──────┼────┼────┤
│  A   │  12  │ 18 │ 22 │
├──────┼──────┼────┼────┤
│  B   │  10  │ 16 │ 21 │
└──────┴──────┴────┴────┘
```

## Panels And Merge

```moonbit nocheck
let table = @tabular.Table::from_rows([
  ["0", "1", "2"],
  ["0", "1", "1"],
  ["1", "1", "2"],
  ["1", "1", "1"],
])

table.panel(@tabular.Panel::header("Runtime Comparison")) |> ignore
table.merge(@tabular.Merge::horizontal()) |> ignore
println(table.to_string())
```

## Highlight And Shadow

```moonbit nocheck
table.highlight(
  @tabular.Highlight::outline_cell(@tabular.Cell::new(1, 1), '*'),
) |> ignore

table.shadow(@tabular.Shadow::new(1)) |> ignore
```

## Split, Extract, Remove

```moonbit nocheck
table.extract_rows(@tabular.Rows::new(0, 2)) |> ignore
table.remove_cols(@tabular.Cols::one(0)) |> ignore
table.split(@tabular.Split::col(2).concat()) |> ignore
```

## Data Transforms

```mbt check
///|
test {
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"]])
  table.rotate(@tabular.Rotate::Left) |> ignore
  assert_eq(table.rows, [["b", "d"], ["a", "c"]])

  table.reverse(@tabular.Reverse::rows(0)) |> ignore
  table.concat(
    @tabular.Concat::horizontal(@tabular.Table::from_rows([["e"], ["f"]])),
  )
  |> ignore
  table.duplicate(
    @tabular.Dup::new(@tabular.Rows::one(1), @tabular.Rows::one(0)),
  )
  |> ignore
  assert_eq(table.rows, [["a", "c", "e"], ["a", "c", "e"]])
}
```

## Composable Settings

`Table::with_` accepts any `TableOption`; `Table::modify` applies a `CellOption`
to an object. Options can be reused and combined with `Settings`, tuples, or
arrays. The trailing underscore avoids MoonBit's `with` keyword.

```mbt check
///|
test {
  let settings = @tabular.Settings::default()
    .with_(@tabular.Style::psql())
    .with_(@tabular.Alignment::left())
    .modify(@tabular.Rows::first(), @tabular.Alignment::center())
  let table = @tabular.Table::from_rows([
      ["Name", "Status"],
      ["task", "pending"],
    ])
    .with_(settings)
    .modify(@tabular.Cell::new(1, 1), "done")
  assert_eq(table.shape(), (2, 2))
  assert_eq(table.rows[1], ["task", "done"])
}
```

## Text Formatting

Tables default to left alignment. Multiline text is aligned as a block;
`AlignmentStrategy::PerLine` aligns its lines independently. `TrimStrategy`
trims displayed whitespace while preserving records and layout dimensions.
`Charset` changes records to remove control characters or expand tabs.

```mbt check
///|
test {
  let table = @tabular.Table::from_rows([["hello"], ["a\nbc"]]).with_(
    (
      @tabular.Alignment::right(),
      @tabular.AlignmentStrategy::PerLine,
      @tabular.Justification::new('.'),
    ),
  )
  assert_eq(
    table.to_string(),
    "+-------+\n| hello |\n+-------+\n| ....a |\n| ...bc |\n+-------+",
  )
}
```

`Color::fg_red()` and other color constructors work as table or cell options.
`Justification::color` colors only the alignment fill. ANSI sequences embedded
in records are excluded from layout width. Wrapping preserves color styles and
OSC8 hyperlinks; truncation closes styles before adding a suffix. A wide character
that cannot fit is replaced by `�`; use `Width::wrap_with` for a custom placeholder.
Text measurement follows Unicode 17.0.0, including emoji presentation and ZWJ
sequences. Advanced width options are still being aligned with upstream; see the
status document.

```mbt check
///|
test {
  let red = @tabular.Color::parse("\u001b[31mtext\u001b[39m")
  assert_eq(red.colorize("hello"), "\u001b[31mhello\u001b[39m")
  assert_true(@tabular.Color::try_from("") is Err(_))
  let table = @tabular.Table::from_rows([[red.colorize("abcdef")]]).modify(
    (0, 0),
    @tabular.Width::wrap(3),
  )
  assert_eq(
    table.to_string(),
    "+-----+\n| \u001b[31mabc\u001b[39m |\n| \u001b[31mdef\u001b[39m |\n+-----+",
  )
}
```

## Validation

The current repository test suite passes:

```bash
moon test
```

## License

Apache-2.0

Adapted upstream code and tests retain their notices in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
