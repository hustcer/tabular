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
let table3 = builder.index().col(0).hide().build()
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

## Validation

The current repository test suite passes:

```bash
moon test
```

## License

Apache-2.0
