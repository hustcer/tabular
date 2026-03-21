///|
fn to_upper(text : String) -> String {
  text.to_upper()
}

///|
test "table ascii style" {
  let table = @tabular.Table::from_rows([
    ["language", "year"],
    ["Rust", "2010"],
    ["MoonBit", "2022"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+----------+------+
      #|| language | year |
      #|+----------+------+
      #||   Rust   | 2010 |
      #|+----------+------+
      #|| MoonBit  | 2022 |
      #|+----------+------+
    ),
  )
}

///|
test "table rounded style" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "0", "0"],
    ["1", "2", "3"],
    ["2", "4", "6"],
  ])
  table.apply(@tabular.Style::rounded()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|╭───┬───┬───╮
      #|│ 0 │ 1 │ 2 │
      #|├───┼───┼───┤
      #|│ 0 │ 0 │ 0 │
      #|├───┼───┼───┤
      #|│ 1 │ 2 │ 3 │
      #|├───┼───┼───┤
      #|│ 2 │ 4 │ 6 │
      #|╰───┴───┴───╯
    ),
  )
}

///|
test "builder insert row and column" {
  let builder = @tabular.Builder::default()
  builder.push_record(["0", "0", "0"])
  builder.push_record(["1", "2", "3"])
  builder.push_record(["2", "4", "6"])
  builder.insert_record(0, ["0", "1", "2"])
  builder.insert_column(0, ["", "0", "1", "2"])
  let table = builder.build()
  table.apply(@tabular.Style::modern()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬───┬───┬───┐
      #|│   │ 0 │ 1 │ 2 │
      #|├───┼───┼───┼───┤
      #|│ 0 │ 0 │ 0 │ 0 │
      #|├───┼───┼───┼───┤
      #|│ 1 │ 1 │ 2 │ 3 │
      #|├───┼───┼───┼───┤
      #|│ 2 │ 2 │ 4 │ 6 │
      #|└───┴───┴───┴───┘
    ),
  )
}

///|
test "builder remove record and column" {
  let builder = @tabular.Builder::default()
  builder.push_record(["1", "2", "3"])
  builder.push_record(["a", "b", "c"])
  builder.push_record(["d", "e", "f"])
  builder.remove_record(1)
  builder.remove_column(2)
  let table = builder.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| 1 | 2 |
      #|+---+---+
      #|| d | e |
      #|+---+---+
    ),
  )
}

///|
test "builder fill empty cells" {
  let builder = @tabular.Builder::default()
  builder.push_record(["1", "2"])
  builder.set_empty("NaN")
  builder.push_record(["a", "b", "c"])
  builder.push_record(["d"])
  let table = builder.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+-----+
      #|| 1 |  2  | NaN |
      #|+---+-----+-----+
      #|| a |  b  |  c  |
      #|+---+-----+-----+
      #|| d | NaN | NaN |
      #|+---+-----+-----+
    ),
  )
}

///|
test "builder clean empty columns" {
  let builder = @tabular.Builder::from_rows([
    ["", "2", "3"],
    ["", "b", "c"],
    ["", "e", "f"],
  ])
  builder.clean()
  let table = builder.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| 2 | 3 |
      #|+---+---+
      #|| b | c |
      #|+---+---+
      #|| e | f |
      #|+---+---+
    ),
  )
}

///|
test "table right alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0"],
    ["0", "0-0"],
    ["1", "1-0"],
  ])
  table.set_alignment(@tabular.Alignment::right()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+
      #|| N | column 0 |
      #|+---+----------+
      #|| 0 |      0-0 |
      #|+---+----------+
      #|| 1 |      1-0 |
      #|+---+----------+
    ),
  )
}

///|
test "table custom padding" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.set_padding(@tabular.Padding::new(1, 1, 1, 1)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+
      #||   |          |
      #|| N | column 0 |
      #||   |          |
      #|+---+----------+
      #||   |          |
      #|| 0 | 0-0      |
      #||   |          |
      #|+---+----------+
    ),
  )
}

///|
test "table width wrap" {
  let table = @tabular.Table::from_rows([["text"], ["abcdef"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.set_width(@tabular.Width::wrap(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+----+
      #|| te |
      #|| xt |
      #|+----+
      #|| ab |
      #|| cd |
      #|| ef |
      #|+----+
    ),
  )
}

///|
test "table width truncate" {
  let table = @tabular.Table::from_rows([["text"], ["abcdef"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.set_width(@tabular.Width::truncate(4, suffix="..")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+------+
      #|| text |
      #|+------+
      #|| ab.. |
      #|+------+
    ),
  )
}

///|
test "table height increase" {
  let table = @tabular.Table::from_rows([["text"], ["a"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.set_height(@tabular.Height::increase(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+------+
      #|| text |
      #||      |
      #|+------+
      #|| a    |
      #||      |
      #|+------+
    ),
  )
}

///|
test "table height limit" {
  let table = @tabular.Table::from_rows([["text"], ["a\nb\nc"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.set_height(@tabular.Height::limit(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+------+
      #|| text |
      #|+------+
      #|| a    |
      #|| b    |
      #|+------+
    ),
  )
}

///|
test "modify columns width truncate with row exclusion" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "abcdef", "ghijkl"],
    ["1", "mnopqr", "stuvwx"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Columns::new(1, 3).not_rows(@tabular.Rows::first()),
    @tabular.Setting::width(@tabular.Width::truncate(2, suffix=".")),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |    a.    |    g.    
      #| 1 |    m.    |    s.    
    ),
  )
}

///|
test "modify segment width wrap" {
  let table = @tabular.Table::from_rows([
    ["N", "text"],
    ["0", "abcdef"],
    ["1", "ghijkl"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_columns(
    @tabular.Columns::one(1),
    @tabular.Setting::width(@tabular.Width::wrap(2)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----+
      #|| N | te |
      #||   | xt |
      #|+---+----+
      #|| 0 | ab |
      #||   | cd |
      #||   | ef |
      #|+---+----+
      #|| 1 | gh |
      #||   | ij |
      #||   | kl |
      #|+---+----+
    ),
  )
}

///|
test "modify rows height increase" {
  let table = @tabular.Table::from_rows([["N", "text"], ["0", "a"], ["1", "b"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_rows(
    @tabular.Rows::one(1),
    @tabular.Setting::height(@tabular.Height::increase(3)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+------+
      #|| N | text |
      #|+---+------+
      #|| 0 | a    |
      #||   |      |
      #||   |      |
      #|+---+------+
      #|| 1 | b    |
      #|+---+------+
    ),
  )
}

///|
test "modify cell column span" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 | 0-0                 | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
    ),
  )
}

///|
test "modify column span for a whole column selection" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::new(1, 3).intersect(@tabular.Columns::one(1)),
    @tabular.Span::column(2),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 | 0-0                 | 0-2      
      #| 1 | 1-0                 | 1-2      
    ),
  )
}

///|
test "column span survives extract columns remap" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(2))
  |> ignore
  table.extract_columns(@tabular.Columns::new(1, 3)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| column 0 | column 1 
      #|-----------+-----------
      #| 0-0                 
      #| 1-0      | 1-1      
    ),
  )
}

///|
test "column span can be removed without losing hidden cell values" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(1))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
    ),
  )
}

///|
test "modify cell row span" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 | 0-0      | 0-1      
      #| 1 |          | 1-1      
    ),
  )
}

///|
test "modify first-column row span" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 | 0-0      | 0-1      
      #|   | 1-0      | 1-1      
    ),
  )
}

///|
test "row span can be removed without losing hidden cell values" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(1)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 | 0-0      | 0-1      
      #| 1 | 1-0      | 1-1      
    ),
  )
}

///|
test "row span survives extract rows remap" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  table.extract_rows(@tabular.Rows::new(1, 4)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| 0 | 0-0 | 0-1 
      #|----+     +------
      #| 1 |     | 1-1 
      #| 2 | 2-0 | 2-1 
    ),
  )
}

///|
test "row span bigger than max clamps to table height" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::row(100)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+   +----------+----------+
      #||   |   0-0    |   0-1    |
      #|+   +----------+----------+
      #||   |   1-0    |   1-1    |
      #|+---+----------+----------+
    ),
  )
}

///|
test "row span on header row under psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_rows(@tabular.Rows::one(0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|- N + column 0 + column 1 -
      #| 1 | 1-0      | 1-1      
    ),
  )
}

///|
test "combined row and column span on one cell" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #|| 0 | 0-0                 | 0-2      |
      #|+---+                     +----------+
      #|| 1 |                     | 1-2      |
      #|+---+----------+----------+----------+
      #|| 2 | 2-0      | 2-1      | 2-2      |
      #|+---+----------+----------+----------+
    ),
  )
}

///|
test "row span invalid position is a no-op" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_cell(@tabular.Cell::new(1000, 1000), @tabular.Span::row(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+---+----------+----------+
      #|| 0 |   0-0    |   0-1    |
      #|+---+----------+----------+
      #|| 1 |   1-0    |   1-1    |
      #|+---+----------+----------+
    ),
  )
}

///|
test "column span negative extends left" {
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 1), @tabular.Span::column(-1))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| b     | c |
      #|+---+---+---+
      #|| d | e | f |
      #|+---+---+---+
    ),
  )
}

///|
test "column span zero extends to full row width and can be removed" {
  let table = @tabular.Table::from_rows([["a", "b", "c"], ["d", "e", "f"]])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::column(0))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| a | b | c |
      #|+---+---+---+
      #|| f         |
      #|+---+---+---+
    ),
  )
  table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::column(1))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| a | b | c |
      #|+---+---+---+
      #|| d | e | f |
      #|+---+---+---+
    ),
  )
}

///|
test "row span negative extends upward" {
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"], ["e", "f"]])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::row(-1)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| c | b |
      #|+   +---+
      #||   | d |
      #|+---+---+
      #|| e | f |
      #|+---+---+
    ),
  )
}

///|
test "row span zero extends to full column height and can be removed" {
  let table = @tabular.Table::from_rows([["a", "b"], ["c", "d"], ["e", "f"]])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::row(0)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| a | f |
      #|+---+   +
      #|| c |   |
      #|+---+   +
      #|| e |   |
      #|+---+---+
    ),
  )
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::row(1)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| a | b |
      #|+---+---+
      #|| c | d |
      #|+---+---+
      #|| e | f |
      #|+---+---+
    ),
  )
}

///|
test "modify cell height limit" {
  let table = @tabular.Table::from_rows([
    ["N", "text"],
    ["0", "a\nb\nc"],
    ["1", "x"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_cell(
    @tabular.Cell::new(1, 1),
    @tabular.Setting::height(@tabular.Height::limit(2)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+------+
      #|| N | text |
      #|+---+------+
      #|| 0 | a    |
      #||   | b    |
      #|+---+------+
      #|| 1 | x    |
      #|+---+------+
    ),
  )
}

///|
test "table vertical alignment center" {
  let table = @tabular.Table::from_rows([
    ["left\ncell", "right one"],
    ["the second column", "and\nhere\nsee\na"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.set_vertical_alignment(@tabular.VerticalAlignment::center()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-------------------+-----------+
      #|| left              | right one |
      #|| cell              |           |
      #|+-------------------+-----------+
      #||                   | and       |
      #|| the second column | here      |
      #||                   | see       |
      #||                   | a         |
      #|+-------------------+-----------+
    ),
  )
}

///|
test "table markdown style" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::markdown()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|| N | column 0 | column 1 |
      #||---|----------|----------|
      #|| 0 |   0-0    |   0-1    |
      #|| 1 |   1-0    |   1-1    |
    ),
  )
}

///|
test "table psql style" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |   0-0    |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "style blank" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::blank()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N  column 0  column 1 
      #| 0    0-0       0-1    
      #| 1    1-0       1-1    
    ),
  )
}

///|
test "style extended" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(@tabular.Style::extended()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|╔═══╦══════════╗
      #|║ N ║ column 0 ║
      #|╠═══╬══════════╣
      #|║ 0 ║   0-0    ║
      #|╚═══╩══════════╝
    ),
  )
}

///|
test "style dots" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(@tabular.Style::dots()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|:..............:
      #|: N : column 0 :
      #|:...:..........:
      #|: 0 :   0-0    :
      #|:..............:
    ),
  )
}

///|
test "style re structured text" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(@tabular.Style::re_structured_text()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|==== ===========
      #| N   column 0 
      #|==== ===========
      #| 0     0-0    
      #|==== ===========
    ),
  )
}

///|
test "style ascii rounded" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(@tabular.Style::ascii_rounded()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|.--------------.
      #|| N | column 0 |
      #|| 0 |   0-0    |
      #|'--------------'
    ),
  )
}

///|
test "style remove horizontal with custom middle line" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(
    @tabular.Style::modern()
    .remove_horizontal()
    .horizontals([
      (
        1,
        @tabular.HorizontalLine::new('─')
        .left('├')
        .intersection('┼')
        .right('┤'),
      ),
    ]),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │
      #|├───┼──────────┼──────────┤
      #|│ 0 │   0-0    │   0-1    │
      #|│ 1 │   1-0    │   1-1    │
      #|└───┴──────────┴──────────┘
    ),
  )
}

///|
test "horizontal line from style modern" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(
    @tabular.Style::modern()
    .remove_horizontal()
    .horizontals([
      (1, @tabular.HorizontalLine::from_style(@tabular.Style::modern())),
    ]),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │
      #|├───┼──────────┼──────────┤
      #|│ 0 │   0-0    │   0-1    │
      #|│ 1 │   1-0    │   1-1    │
      #|└───┴──────────┴──────────┘
    ),
  )
}

///|
test "style remove horizontal preserves custom lines" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(
    @tabular.Style::modern()
    .horizontals([
      (1, @tabular.HorizontalLine::from_style(@tabular.Style::modern())),
    ])
    .remove_horizontal(),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │
      #|├───┼──────────┼──────────┤
      #|│ 0 │   0-0    │   0-1    │
      #|│ 1 │   1-0    │   1-1    │
      #|└───┴──────────┴──────────┘
    ),
  )
}

///|
test "style remove horizontals clears custom lines" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(
    @tabular.Style::modern()
    .horizontals([
      (1, @tabular.HorizontalLine::from_style(@tabular.Style::modern())),
    ])
    .remove_horizontals(),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │
      #|│ 0 │   0-0    │   0-1    │
      #|│ 1 │   1-0    │   1-1    │
      #|└───┴──────────┴──────────┘
    ),
  )
}

///|
test "style frame changes" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(
    @tabular.Style::modern().remove_top().remove_bottom().remove_horizontal(),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|│ N │ column 0 │ column 1 │
      #|│ 0 │   0-0    │   0-1    │
      #|│ 1 │   1-0    │   1-1    │
    ),
  )
}

///|
test "style empty top" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(@tabular.Style::empty().top('-')) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|----------------
      #| N  column 0 
      #| 0    0-0    
    ),
  )
}

///|
test "style empty left right vertical horizontal" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(
    @tabular.Style::empty().left('|').right('*').vertical('#').horizontal('='),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|| N # column 0 *
      #|================
      #|| 0 #   0-0    *
    ),
  )
}

///|
test "style empty custom horizontal only" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(
    @tabular.Style::empty().horizontals([(1, @tabular.HorizontalLine::new('-'))]),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N  column 0  column 1 
      #|---------------------------
      #| 0    0-0       0-1    
      #| 1    1-0       1-1    
    ),
  )
}

///|
test "style remove vertical from full custom frame" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(
    @tabular.Style::empty()
    .top('-')
    .bottom('+')
    .left('|')
    .right('*')
    .horizontal('x')
    .vertical('#')
    .intersection_bottom('@')
    .intersection_top('!')
    .intersection_left('=')
    .intersection_right('$')
    .intersection('+')
    .corner_top_left(';')
    .corner_bottom_left('?')
    .corner_top_right('.')
    .corner_bottom_right('%')
    .remove_vertical(),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|;--------------.
      #|| N  column 0 *
      #|=xxxxxxxxxxxxxx$
      #|| 0    0-0    *
      #|?++++++++++++++%
    ),
  )
}

///|
test "modify segment alignment left" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 | 0-0      | 0-1      
      #| 1 | 1-0      | 1-1      
    ),
  )
}

///|
test "modify rows alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::new(1, 3),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+---+----------+----------+
      #|| 0 |      0-0 |      0-1 |
      #|+---+----------+----------+
      #|| 1 |      1-0 |      1-1 |
      #|+---+----------+----------+
    ),
  )
}

///|
test "modify columns vertical alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "E\nnde\navou\nros", "0-1"],
    ["1", "Red\nHat", "https://\nwww\n.\nredhat\n.com\n/en"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::new(1, 3),
    @tabular.Setting::vertical_alignment(@tabular.VerticalAlignment::bottom()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |    E     |          
      #|   |   nde    |          
      #|   |   avou   |          
      #|   |   ros    |   0-1    
      #| 1 |          | https:// 
      #|   |          |   www    
      #|   |          |    .     
      #|   |          |  redhat  
      #|   |   Red    |   .com   
      #|   |   Hat    |   /en    
    ),
  )
}

///|
test "modify rows padding" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0"],
    ["0", "0-0"],
    ["1", "1-0"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::new(1, 3),
    @tabular.Setting::padding(@tabular.Padding::new(1, 1, 0, 2)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 
      #|----+-----------
      #| 0 | 0-0      
      #|   |          
      #|   |          
      #| 1 | 1-0      
      #|   |          
      #|   |          
    ),
  )
}

///|
test "modify columns skip and not first" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::all().not(@tabular.Columns::first()).skip(2),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |   0-0    |   0-1    |      0-2 
      #| 1 |   1-0    |   1-1    |      1-2 
      #| 2 |   2-0    |   2-1    |      2-2 
    ),
  )
}

///|
test "modify columns step by" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::all().step_by(3),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |   0-0    |   0-1    |      0-2 
      #| 1 |   1-0    |   1-1    |      1-2 
      #| 2 |   2-0    |   2-1    |      2-2 
    ),
  )
}

///|
test "modify columns filter" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::all().filter(entity => {
      match entity {
        Column(index) => index == 1 || index == 3
        _ => false
      }
    }),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |      0-0 |   0-1    |      0-2 
      #| 1 |      1-0 |   1-1    |      1-2 
      #| 2 |      2-0 |   2-1    |      2-2 
    ),
  )
}

///|
test "modify segment skip one cell" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all().skip(1),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |      0-0 |      0-1 |      0-2 
      #| 1 |      1-0 |      1-1 |      1-2 
      #| 2 |      2-0 |      2-1 |      2-2 
    ),
  )
}

///|
test "modify rows step by" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_rows(
    @tabular.Rows::all().skip(1).step_by(2),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+---+----------+----------+
      #|| 0 |      0-0 |      0-1 |
      #|+---+----------+----------+
      #|| 1 | 1-0      | 1-1      |
      #|+---+----------+----------+
      #|| 2 |      2-0 |      2-1 |
      #|+---+----------+----------+
    ),
  )
}

///|
test "modify segment range" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::new(1, 3, 1, 3),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |      0-0 |      0-1 
      #| 1 |      1-0 |      1-1 
    ),
  )
}

///|
test "modify single row with one" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_rows(
    @tabular.Rows::one(2),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+---+----------+----------+
      #|| 0 | 0-0      | 0-1      |
      #|+---+----------+----------+
      #|| 1 |      1-0 |      1-1 |
      #|+---+----------+----------+
    ),
  )
}

///|
test "modify single column with one" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::one(0),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |   0-0    |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "modify cell alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(
    @tabular.Cell::new(1, 1),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |      0-0 |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "modify last row alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_rows(
    @tabular.Rows::last(),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+---+----------+----------+
      #|| 0 | 0-0      | 0-1      |
      #|+---+----------+----------+
      #|| 1 | 1-0      | 1-1      |
      #|+---+----------+----------+
      #|| 2 |      2-0 |      2-1 |
      #|+---+----------+----------+
    ),
  )
}

///|
test "modify last column alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::last(),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |   0-0    |      0-1 
      #| 1 |   1-0    |      1-1 
    ),
  )
}

///|
test "modify row by last offset" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0"],
    ["0", "0-0"],
    ["1", "1-0"],
    ["2", "2-0"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_rows(
    @tabular.Rows::last_offset(1),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+
      #|| N | column 0 |
      #|+---+----------+
      #|| 0 | 0-0      |
      #|+---+----------+
      #|| 1 |      1-0 |
      #|+---+----------+
      #|| 2 | 2-0      |
      #|+---+----------+
    ),
  )
}

///|
test "modify column by last offset" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::last_offset(1),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |   0-0    |      0-1 |   0-2    
      #| 1 |   1-0    |      1-1 |   1-2    
    ),
  )
}

///|
test "modify intersect rows and columns" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Columns::new(1, 3).intersect(@tabular.Rows::new(1, 3)),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |      0-0 |      0-1 |   0-2    
      #| 1 |      1-0 |      1-1 |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "modify intersect rows and columns with skip" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Rows::new(1, 3).intersect(@tabular.Columns::new(1, 4)).skip(2),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |   0-0    |   0-1    |      0-2 
      #| 1 |      1-0 |      1-1 |      1-2 
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "modify inverse columns" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Columns::one(0).inverse(),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 |      0-0 |      0-1 |      0-2 
      #| 1 |      1-0 |      1-1 |      1-2 
    ),
  )
}

///|
test "modify inverse cell" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Cell::new(0, 0).inverse(),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |      0-0 |      0-1 
      #| 1 |      1-0 |      1-1 
    ),
  )
}

///|
test "modify union of row and column segments" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1).and_columns(@tabular.Columns::one(2)),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |      0-0 |      0-1 
      #| 1 | 1-0      |      1-1 
    ),
  )
}

///|
test "modify union of row selectors" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1).and_(@tabular.Rows::one(3)),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |      0-0 |      0-1 
      #| 1 | 1-0      | 1-1      
      #| 2 |      2-0 |      2-1 
    ),
  )
}

///|
test "modify row not column with ergonomic helper" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1).not_columns(@tabular.Columns::one(1)),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 | 0-0      |      0-1 
      #| 1 | 1-0      | 1-1      
    ),
  )
}

///|
test "modify column not row with ergonomic helper" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Columns::one(2).not_rows(@tabular.Rows::first()),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 | 0-0      |      0-1 
      #| 1 | 1-0      |      1-1 
    ),
  )
}

///|
test "modify segment difference by cell" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1)
    .as_segment()
    .and_(@tabular.Columns::one(2).as_segment())
    .not_(@tabular.Cell::new(1, 2).as_segment()),
    @tabular.Setting::alignment(@tabular.Alignment::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |      0-0 | 0-1      
      #| 1 | 1-0      |      1-1 
    ),
  )
}

///|
test "format full segment surround" {
  let table = @tabular.Table::from_rows([["N", "name"], ["0", "alice"]])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(@tabular.Format::surround("[", "]")),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+---------+
      #|| [N] | [name]  |
      #|+-----+---------+
      #|| [0] | [alice] |
      #|+-----+---------+
    ),
  )
}

///|
test "format first row surround" {
  let table = @tabular.Table::from_rows([["N", "name"], ["0", "alice"]])
  table.apply(@tabular.Style::markdown()) |> ignore
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::format(@tabular.Format::surround(":", "")),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|| :N | :name |
      #||----|-------|
      #|| 0  | alice |
    ),
  )
}

///|
test "format first column surround" {
  let table = @tabular.Table::from_rows([
    ["N", "name"],
    ["0", "alice"],
    ["1", "bob"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::one(0),
    @tabular.Setting::format(@tabular.Format::surround("(x) ", "")),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| (x) N | name  
      #|--------+--------
      #| (x) 0 | alice 
      #| (x) 1 |  bob  
    ),
  )
}

///|
test "format cell value" {
  let table = @tabular.Table::from_rows([
    ["N", "name"],
    ["0", "alice"],
    ["1", "bob"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(
    @tabular.Cell::new(2, 1),
    @tabular.Setting::format(@tabular.Format::value("X")),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | name  
      #|----+--------
      #| 0 | alice 
      #| 1 |   X   
    ),
  )
}

///|
test "format content full segment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(
      @tabular.Format::content(value => "[" + value + "]"),
    ),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+------------+------------+------------+
      #|| [N] | [column 0] | [column 1] | [column 2] |
      #|+-----+------------+------------+------------+
      #|| [0] |   [0-0]    |   [0-1]    |   [0-2]    |
      #|+-----+------------+------------+------------+
      #|| [1] |   [1-0]    |   [1-1]    |   [1-2]    |
      #|+-----+------------+------------+------------+
      #|| [2] |   [2-0]    |   [2-1]    |   [2-2]    |
      #|+-----+------------+------------+------------+
    ),
  )
}

///|
test "format content using function" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::markdown()) |> ignore
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::format(@tabular.Format::content(to_upper)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|| N | COLUMN 0 | COLUMN 1 |
      #||---|----------|----------|
      #|| 0 |   0-0    |   0-1    |
      #|| 1 |   1-0    |   1-1    |
    ),
  )
}

///|
test "format positioned first row" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::markdown()) |> ignore
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::format(
      @tabular.Format::positioned((value, row, column) => {
        if row == 0 && column < 3 {
          "(" + row.to_string() + ", " + column.to_string() + ")"
        } else {
          value
        }
      }),
    ),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|| (0, 0) | (0, 1) | (0, 2) | column 2 |
      #||--------|--------|--------|----------|
      #||   0    |  0-0   |  0-1   |   0-2    |
      #||   1    |  1-0   |  1-1   |   1-2    |
    ),
  )
}

///|
test "format multiline content" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "E\nnde\navou\nros"],
    ["1", "1-0", "https://\nwww\n.\nredhat\n.com\n/en"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(
      @tabular.Format::content(value => "(x) " + value).multiline(),
    ),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| (x) N | (x) column 0 | (x) column 1 
      #|--------+--------------+---------------
      #| (x) 0 |   (x) 0-0    |    (x) E     
      #|       |              |   (x) nde    
      #|       |              |   (x) avou   
      #|       |              |   (x) ros    
      #| (x) 1 |   (x) 1-0    | (x) https:// 
      #|       |              |   (x) www    
      #|       |              |    (x) .     
      #|       |              |  (x) redhat  
      #|       |              |   (x) .com   
      #|       |              |   (x) /en    
    ),
  )
}

///|
test "format intersection content" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Columns::new(1, 3).intersect(@tabular.Rows::new(1, 3)),
    @tabular.Setting::format(@tabular.Format::content(value => "(x) " + value)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|----+----------+----------+-----------
      #| 0 | (x) 0-0  | (x) 0-1  |   0-2    
      #| 1 | (x) 1-0  | (x) 1-1  |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "format inverse columns content" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Columns::one(0).inverse(),
    @tabular.Setting::format(@tabular.Format::content(value => "(x) " + value)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | (x) column 0 | (x) column 1 | (x) column 2 
      #|----+--------------+--------------+---------------
      #| 0 |   (x) 0-0    |   (x) 0-1    |   (x) 0-2    
      #| 1 |   (x) 1-0    |   (x) 1-1    |   (x) 1-2    
    ),
  )
}

///|
test "format union and difference content" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Columns::one(0)
    .and_rows(@tabular.Rows::one(0))
    .not_cell(@tabular.Cell::new(0, 0)),
    @tabular.Setting::format(@tabular.Format::content(value => "(x) " + value)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|   N   | (x) column 0 | (x) column 1 | (x) column 2 
      #|--------+--------------+--------------+---------------
      #| (x) 0 |     0-0      |     0-1      |     0-2      
      #| (x) 1 |     1-0      |     1-1      |     1-2      
      #| (x) 2 |     2-0      |     2-1      |     2-2      
    ),
  )
}

///|
test "format content keeps padding and alignment" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::padding(@tabular.Padding::new(3, 1, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(
      @tabular.Format::content(value => "[" + value + "]"),
    ),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-------+--------------+--------------+
      #||   [N] |   [column 0] |   [column 1] |
      #|+-------+--------------+--------------+
      #||   [0] |   [0-0]      |   [0-1]      |
      #|+-------+--------------+--------------+
      #||   [1] |   [1-0]      |   [1-1]      |
      #|+-------+--------------+--------------+
    ),
  )
}

///|
test "format content then width truncate" {
  let table = @tabular.Table::from_rows([["name"], ["alphabet"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(
      @tabular.Format::content(value => "[" + value + "]"),
    ),
  )
  |> ignore
  table.set_width(@tabular.Width::truncate(6, suffix="...")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+--------+
      #|| [name] |
      #|+--------+
      #|| [al... |
      #|+--------+
    ),
  )
}

///|
test "format content then width wrap" {
  let table = @tabular.Table::from_rows([["name"], ["alphabet"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(
      @tabular.Format::content(value => "[" + value + "]"),
    ),
  )
  |> ignore
  table.set_width(@tabular.Width::wrap(4)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+------+
      #|| [nam |
      #|| e]   |
      #|+------+
      #|| [alp |
      #|| habe |
      #|| t]   |
      #|+------+
    ),
  )
}

///|
test "format multiline then height limit" {
  let table = @tabular.Table::from_rows([["text"], ["a\nb\nc"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(
      @tabular.Format::content(value => "<" + value + ">").multiline(),
    ),
  )
  |> ignore
  table.set_height(@tabular.Height::limit(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+--------+
      #|| <text> |
      #|+--------+
      #|| <a>    |
      #|| <b>    |
      #|+--------+
    ),
  )
}

///|
test "extract segment keeps scoped width" {
  let table = @tabular.Table::from_rows([
    ["N", "text", "more"],
    ["0", "abcdef", "ghijkl"],
    ["1", "mnopqr", "stuvwx"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_columns(
    @tabular.Columns::one(1),
    @tabular.Setting::width(@tabular.Width::wrap(2)),
  )
  |> ignore
  table.extract_segment(@tabular.Rows::all(), @tabular.Columns::new(1, 3))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+----+--------+
      #|| te | more   |
      #|| xt |        |
      #|+----+--------+
      #|| ab | ghijkl |
      #|| cd |        |
      #|| ef |        |
      #|+----+--------+
      #|| mn | stuvwx |
      #|| op |        |
      #|| qr |        |
      #|+----+--------+
    ),
  )
}

///|
test "remove columns with scoped width on remaining column" {
  let table = @tabular.Table::from_rows([
    ["N", "text", "drop"],
    ["0", "abcdef", "X"],
    ["1", "ghijkl", "Y"],
  ])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_columns(
    @tabular.Columns::one(1),
    @tabular.Setting::width(@tabular.Width::truncate(3)),
  )
  |> ignore
  table.remove_columns(@tabular.Columns::last()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+
      #|| N | tex |
      #|+---+-----+
      #|| 0 | abc |
      #|+---+-----+
      #|| 1 | ghi |
      #|+---+-----+
    ),
  )
}

///|
test "one column mixed height layout" {
  let table = @tabular.Table::from_rows([["head"], ["a\nb"], ["c"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+------+
      #|| head |
      #|+------+
      #|| a    |
      #|| b    |
      #|+------+
      #|| c    |
      #|+------+
    ),
  )
}

///|
test "one row width wrap layout" {
  let table = @tabular.Table::from_rows([["abcdef", "ghijkl"]])
  table.set_alignment(@tabular.Alignment::left()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::width(@tabular.Width::wrap(3)),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+
      #|| abc | ghi |
      #|| def | jkl |
      #|+-----+-----+
    ),
  )
}

///|
test "padding by column name" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_by_column_name(
    @tabular.ByColumnName::new("column 0"),
    @tabular.Setting::padding(@tabular.Padding::new(3, 3, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N |   column 0   | column 1 
      #|----+--------------+-----------
      #| 0 |     0-0      |   0-1    
      #| 1 |     1-0      |   1-1    
    ),
  )
}

///|
test "padding by column name not first row" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_by_column_name(
    @tabular.ByColumnName::new("0-1"),
    @tabular.Setting::padding(@tabular.Padding::new(3, 3, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |   0-0    |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "padding by column name not existing" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_by_column_name(
    @tabular.ByColumnName::new("column 01123123"),
    @tabular.Setting::padding(@tabular.Padding::new(3, 3, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|----+----------+-----------
      #| 0 |   0-0    |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "remove rows" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.remove_rows(@tabular.Rows::new(1, 3)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+
      #|| N | column 0 | column 1 |
      #|+---+----------+----------+
      #|| 2 |   2-0    |   2-1    |
      #|+---+----------+----------+
    ),
  )
}

///|
test "remove header psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.remove_rows(@tabular.Rows::first()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| 0 | 0-0 | 0-1 
      #|----+-----+------
      #| 1 | 1-0 | 1-1 
    ),
  )
}

///|
test "remove first column psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.remove_columns(@tabular.Columns::first()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| column 0 | column 1 
      #|-----------+-----------
      #|   0-0    |   0-1    
      #|   1-0    |   1-1    
    ),
  )
}

///|
test "remove column by name" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.remove_by_column_name(@tabular.ByColumnName::new("column 1")) |> ignore
  table.remove_by_column_name(@tabular.ByColumnName::new("column 3")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 2 
      #|----+----------+-----------
      #| 0 |   0-0    |   0-2    
      #| 1 |   1-0    |   1-2    
    ),
  )
}

///|
test "remove all columns yields empty" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.apply(@tabular.Style::psql()) |> ignore
  table.remove_columns(@tabular.Columns::all()) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "extract segment full" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::alignment(@tabular.Alignment::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::padding(@tabular.Padding::new(3, 1, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(@tabular.Format::surround("[", "]")),
  )
  |> ignore
  table.extract_segment(@tabular.Rows::all(), @tabular.Columns::all()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-------+--------------+--------------+
      #||   [N] |   [column 0] |   [column 1] |
      #|+-------+--------------+--------------+
      #||   [0] |   [0-0]      |   [0-1]      |
      #|+-------+--------------+--------------+
      #||   [1] |   [1-0]      |   [1-1]      |
      #|+-------+--------------+--------------+
    ),
  )
}

///|
test "extract segment skip top row" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.extract_segment(@tabular.Rows::new(1, 4), @tabular.Columns::all())
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+-----+
      #|| 0 | 0-0 | 0-1 |
      #|+---+-----+-----+
      #|| 1 | 1-0 | 1-1 |
      #|+---+-----+-----+
      #|| 2 | 2-0 | 2-1 |
      #|+---+-----+-----+
    ),
  )
}

///|
test "extract segment skip first column" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.extract_segment(@tabular.Rows::all(), @tabular.Columns::new(1, 3))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+----------+----------+
      #|| column 0 | column 1 |
      #|+----------+----------+
      #||   0-0    |   0-1    |
      #|+----------+----------+
      #||   1-0    |   1-1    |
      #|+----------+----------+
    ),
  )
}

///|
test "extract bottom right square" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.extract_segment(@tabular.Rows::new(2, 4), @tabular.Columns::new(2, 4))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+
      #|| 1-1 | 1-2 |
      #|+-----+-----+
      #|| 2-1 | 2-2 |
      #|+-----+-----+
    ),
  )
}

///|
test "extract empty segment" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.extract_segment(@tabular.Rows::new(1, 1), @tabular.Columns::new(1, 1))
  |> ignore
  inspect(table.to_string(), content="")
}

///|
test "extract after remove header" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_rows(@tabular.Rows::first()) |> ignore
  table.extract_segment(@tabular.Rows::new(1, 2), @tabular.Columns::new(1, 2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+
      #|| 1-0 |
      #|+-----+
    ),
  )
}
