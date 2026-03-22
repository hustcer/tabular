# Tabular

A MoonBit library for pretty-printing tables in terminal. Ported from the Rust [tabled](https://github.com/zhiburt/tabled) library.

## Features

- 11 built-in style presets (ascii, modern, rounded, markdown, psql, etc.)
- Customizable borders, corners, intersections, and horizontal lines
- Row/column/cell-level alignment, padding, width, and height control
- Powerful selector system for targeting rows, columns, segments, and cells
- Column and row spans with negative/zero span support
- Panel (header/footer/horizontal/vertical), Merge, Highlight, Shadow
- Split and border correction for advanced table reshaping
- Extract and Remove operations with config remapping
- Builder pattern with index/transpose support
- 290+ passing tests

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
table.apply(@tabular.Style::ascii())
table.apply(@tabular.Style::modern())
table.apply(@tabular.Style::rounded())
table.apply(@tabular.Style::extended())
table.apply(@tabular.Style::dots())
table.apply(@tabular.Style::empty())
table.apply(@tabular.Style::blank())
table.apply(@tabular.Style::re_structured_text())
table.apply(@tabular.Style::ascii_rounded())
table.apply(@tabular.Style::markdown())
table.apply(@tabular.Style::psql())
```

### All Style Examples

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

**empty**

```
 language  year
   Rust    2010
 MoonBit   2022
```

**blank**

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

### Custom Borders

```moonbit nocheck
let style = @tabular.Style::ascii()
  .top('─').bottom('─').left('│').right('│')
  .horizontal('─').vertical('│')
  .corner_top_left('┌').corner_top_right('┐')
  .corner_bottom_left('└').corner_bottom_right('┘')
table.apply(style) |> ignore
```

### Removing Borders

```moonbit nocheck
let style = @tabular.Style::modern()
  .remove_horizontal()
  .remove_vertical()
table.apply(style) |> ignore
```

### Custom Horizontal Lines

```moonbit nocheck
let style = @tabular.Style::ascii()
  .remove_horizontal()
  .horizontals([@tabular.HorizontalLine::new(1, '-', '+', '+', '+')])
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

### Insert and Remove

```moonbit nocheck
let builder = @tabular.Builder::default()
builder.push_record(["0", "0", "0"])
builder.push_record(["1", "2", "3"])
builder.insert_record(0, ["A", "B", "C"])  // Insert header row
builder.insert_col(0, ["#", "1", "2"])  // Insert index column
builder.remove_record(2)                    // Remove a row
builder.remove_col(3)                    // Remove a column
let table = builder.build()
```

### Fill Empty Cells

```moonbit nocheck
let builder = @tabular.Builder::default()
builder.set_empty("N/A")
builder.push_record(["a", "b", "c"])
builder.push_record(["d"])  // Missing cells filled with "N/A"
let table = builder.build()
```

### Clean Empty Rows/Columns

```moonbit nocheck
let builder = @tabular.Builder::from_rows([
  ["", "data", ""],
  ["", "more", ""],
])
builder.clean()  // Removes all-empty columns and rows
let table = builder.build()
```

### Index and Transpose

```moonbit nocheck
///|
let builder = @tabular.Builder::from_rows([
  ["Name", "Age"],
  ["Alice", "30"],
  ["Bob", "25"],
])

// Add auto-generated index

///|
let table = builder.index().build()

// Transpose the table (swap rows and columns)

///|
let builder2 = @tabular.Builder::from_rows([["Name", "Age"], ["Alice", "30"]])

///|
let table2 = builder2.index().transpose().build()

// Use a column as index, hide the default index

///|
let builder3 = @tabular.Builder::from_rows([["Name", "Age"], ["Alice", "30"]])

///|
let table3 = builder3.index().col(0).hide().build()
```

## Alignment

```moonbit nocheck
// Global alignment
table.set_align(@tabular.Align::left()) |> ignore
table.set_align(@tabular.Align::right()) |> ignore
table.set_align(@tabular.Align::center()) |> ignore

// Per-row alignment
table.modify_rows(
  @tabular.Rows::first(),
  @tabular.Setting::align(@tabular.Align::center()),
)

// Per-column alignment
table.modify_cols(
  @tabular.Cols::one(1),
  @tabular.Setting::align(@tabular.Align::right()),
)
```

### Vertical Alignment

```moonbit nocheck
table.set_valign(@tabular.VAlign::top()) |> ignore
table.set_valign(@tabular.VAlign::center()) |> ignore
table.set_valign(@tabular.VAlign::bottom()) |> ignore
```

## Padding

```moonbit nocheck
// Global padding: left, right, top, bottom
table.apply(@tabular.Padding::new(2, 2, 0, 0)) |> ignore

// Per-row padding
table.modify_rows(
  @tabular.Rows::first(),
  @tabular.Setting::padding(@tabular.Padding::new(1, 1, 1, 1)),
)
```

## Width and Height

```moonbit nocheck
// Wrap text at width 10
table.apply(@tabular.Width::wrap(10)) |> ignore

// Truncate text at width 5 with "..." suffix
table.apply(@tabular.Width::truncate_with_suffix(5, "...")) |> ignore

// Set minimum height
table.apply(@tabular.Height::increase(3)) |> ignore

// Limit height
table.apply(@tabular.Height::limit(2)) |> ignore

// Per-column width
table.modify_cols(
  @tabular.Cols::one(0),
  @tabular.Setting::width(@tabular.Width::wrap(8)),
)

// Per-row height
table.modify_rows(
  @tabular.Rows::one(1),
  @tabular.Setting::height(@tabular.Height::increase(3)),
)
```

## Selectors

Selectors let you target specific rows, columns, cells, or segments for modification.

### Row Selectors

```moonbit nocheck
@tabular.Rows::all()           // All rows
@tabular.Rows::first()         // First row (header)
@tabular.Rows::last()          // Last row
@tabular.Rows::one(2)          // Row at index 2
@tabular.Rows::new(1, 3)       // Rows 1..3 (exclusive)
@tabular.Rows::first_offset(1) // Second row (first + 1)
@tabular.Rows::last_offset(1)  // Second-to-last row
@tabular.Rows::all().skip(1)         // All except first
@tabular.Rows::all().step_by(2)      // Every other row
@tabular.Rows::all().filter(fn(i) { i % 2 == 0 })  // Even-indexed rows
```

### Column Selectors

```moonbit nocheck
@tabular.Cols::all()           // All columns
@tabular.Cols::first()         // First column
@tabular.Cols::last()          // Last column
@tabular.Cols::one(1)          // Column at index 1
@tabular.Cols::new(0, 2)       // Columns 0..2
```

### Combining Selectors

```moonbit nocheck
// Union: rows AND columns
let rows = @tabular.Rows::first()
let cols = @tabular.Cols::last()
table.modify_segment(
  rows.as_segment().and_cols(cols),
  @tabular.Setting::align(@tabular.Align::right()),
)

// Difference: rows NOT columns
table.modify_segment(
  @tabular.Rows::all().as_segment().not_(@tabular.Cols::one(0).as_segment()),
  @tabular.Setting::format(@tabular.Format::surround("[", "]")),
)

// Intersection
table.modify_segment(
  @tabular.Rows::first().intersect(@tabular.Cols::last()).as_segment(),
  @tabular.Setting::align(@tabular.Align::center()),
)

// Inverse
table.modify_segment(
  @tabular.Cell::new(0, 0).inverse().as_segment(),
  @tabular.Setting::format(@tabular.Format::surround("*", "*")),
)
```

### Cell and Segment

```moonbit nocheck
// Single cell
table.modify_cell(
  @tabular.Cell::new(1, 2),
  @tabular.Setting::align(@tabular.Align::right()),
)

// Segment (row range x column range)
table.modify_segment(
  @tabular.Segment::new(1, 3, 0, 2),
  @tabular.Setting::padding(@tabular.Padding::new(2, 2, 0, 0)),
)

// By column name
table.modify_by_col_name(
  @tabular.ByColName::new("Name"),
  @tabular.Setting::align(@tabular.Align::left()),
)
```

## Format

```moonbit nocheck
// Replace all cell content
table.modify_segment(
  @tabular.Segment::all(),
  @tabular.Setting::format(@tabular.Format::value("X")),
)

// Surround with prefix/suffix
table.modify_rows(
  @tabular.Rows::all().skip(1),
  @tabular.Setting::format(@tabular.Format::surround("[", "]")),
)

// Transform content with a function
table.modify_segment(
  @tabular.Segment::all(),
  @tabular.Setting::format(
    @tabular.Format::content(fn(value) { value.to_upper() }),
  ),
)

// Position-aware formatting
table.modify_segment(
  @tabular.Segment::all(),
  @tabular.Setting::format(
    @tabular.Format::positioned(
      fn(value, row, col) {
        if row == 0 { value.to_upper() } else { value }
      },
    ),
  ),
)

// Multiline formatting (applies per line)
table.modify_segment(
  @tabular.Segment::all(),
  @tabular.Setting::format(
    @tabular.Format::content(fn(value) { "> " + value }).multiline(),
  ),
)
```

## Spans

### Column Span

```moonbit nocheck
// Span cell (1,0) across 3 columns
table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::col(3))

// Full-row span (span 0 = entire row width)
table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::col(0))

// Negative span: span leftward from the target cell
table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::col(-1))

// Remove span
table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::col(1))
```

### Row Span

```moonbit nocheck
// Span cell (0,0) across 2 rows
table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::row(2))

// Full-column span (span 0 = entire column height)
table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::row(0))

// Negative span: span upward from the target cell
table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::row(-1))
```

## Panel

```moonbit nocheck
// Add header panel
table.panel(@tabular.Panel::header("Runtime Comparison"))

// Add footer panel
table.panel(@tabular.Panel::footer("Source: GitHub"))

// Insert horizontal panel at row index
table.panel(@tabular.Panel::horizontal(2, "--- Section ---"))

// Insert vertical panel at column index
table.panel(@tabular.Panel::vertical(0, "Index"))

// Vertical panel with text wrapping at specified width
table.panel(@tabular.Panel::vertical_with_width(0, "Long text here", 5))
```

## Merge

```moonbit nocheck
// Merge adjacent duplicate cells horizontally
table.merge(@tabular.Merge::horizontal())

// Merge adjacent duplicate cells vertically
table.merge(@tabular.Merge::vertical())
```

## Highlight

```moonbit nocheck
// Highlight a single cell with a border character
table.highlight(
  @tabular.Highlight::outline_cell(@tabular.Cell::new(1, 1), '*'),
)

// Highlight entire rows
table.highlight(
  @tabular.Highlight::outline_rows(@tabular.Rows::first(), '#'),
)

// Highlight with a custom border
let border = @tabular.Border::new()
  .top('-').bottom('-').left('|').right('|')
  .corner_top_left('+').corner_top_right('+')
  .corner_bottom_left('+').corner_bottom_right('+')
table.highlight(
  @tabular.Highlight::new_cell(@tabular.Cell::new(0, 0)).with_border(border),
)
```

## Shadow

```moonbit nocheck
// Add shadow with size 1 (default: bottom-right, fill '▒')
let shadow = @tabular.Shadow::new(1)
table.shadow(shadow)

// Custom shadow direction and fill
let shadow = @tabular.Shadow::new(2)
shadow.set_fill('#')
shadow.set_top()     // Shadow on top
shadow.set_left()    // Shadow on left
table.shadow(shadow)
```

## Extract and Remove

```moonbit nocheck
// Extract specific rows
table.extract_rows(@tabular.Rows::new(0, 2))

// Extract specific columns
table.extract_cols(@tabular.Cols::new(1, 3))

// Extract a segment (rows x columns intersection)
table.extract_segment(
  @tabular.Rows::new(1, 3),
  @tabular.Cols::new(0, 2),
)

// Remove rows
table.remove_rows(@tabular.Rows::first())

// Remove columns
table.remove_cols(@tabular.Cols::new(0, 2))

// Remove column by header name
table.remove_by_col_name(@tabular.ByColName::new("Age"))
```

## Split

```moonbit nocheck
// Split table at column 2 (zip mode by default)
table.split(@tabular.Split::col(2))

// Split and concatenate instead of zip
table.split(@tabular.Split::col(2).concat())

// Split at row 1, retain all cells (no cleanup)
table.split(@tabular.Split::row(1).retain())

// Split with clean mode (default: removes empty rows/columns)
table.split(@tabular.Split::col(2).clean())
```

## Border Correction

Fix border junction characters after applying spans:

```moonbit nocheck
table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::col(2))
table.correct_borders()
```

## License

Apache-2.0
