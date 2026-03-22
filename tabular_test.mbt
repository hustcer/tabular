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
test "table right align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0"],
    ["0", "0-0"],
    ["1", "1-0"],
  ])
  table.set_align(@tabular.Align::right()) |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
      #|---+----------+----------
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
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
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(2))
  |> ignore
  table.extract_columns(@tabular.Columns::new(1, 3)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| column 0 | column 1 
      #|----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
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
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(1)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  table.extract_rows(@tabular.Rows::new(1, 4)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| 0 | 0-0 | 0-1 
      #|---+     +-----
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(@tabular.Rows::one(0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N + column 0 + column 1 
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
    @tabular.Setting::align(@tabular.Align::left()),
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
    @tabular.Setting::align(@tabular.Align::left()),
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
    @tabular.Setting::align(@tabular.Align::left()),
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
    @tabular.Setting::align(@tabular.Align::left()),
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
    @tabular.Setting::align(@tabular.Align::left()),
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
test "column span negative survives extract columns when anchor column is removed" {
  let table = @tabular.Table::from_rows([
    ["a", "b", "c", "d", "e"],
    ["f", "g", "h", "i", "j"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 3), @tabular.Span::column(-2))
  |> ignore
  table.extract_columns(@tabular.Columns::new(2, 5)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| c | d | e |
      #|+---+---+---+
      #|| i     | j |
      #|+---+---+---+
    ),
  )
}

///|
test "row span zero survives extract rows when anchor row is removed" {
  let table = @tabular.Table::from_rows([
    ["a", "b"],
    ["c", "d"],
    ["e", "f"],
    ["g", "h"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 1), @tabular.Span::row(0)) |> ignore
  table.extract_rows(@tabular.Rows::new(1, 4)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| c | h |
      #|+---+   +
      #|| e |   |
      #|+---+   +
      #|| g |   |
      #|+---+---+
    ),
  )
}

///|
test "column span zero survives remove first columns" {
  let table = @tabular.Table::from_rows([
    ["a", "b", "c", "d"],
    ["e", "f", "g", "h"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 3), @tabular.Span::column(0))
  |> ignore
  table.remove_columns(@tabular.Columns::new(0, 2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| c | d |
      #|+---+---+
      #|| h     |
      #|+---+---+
    ),
  )
}

///|
test "row span negative survives remove first row" {
  let table = @tabular.Table::from_rows([
    ["a", "b"],
    ["c", "d"],
    ["e", "f"],
    ["g", "h"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::row(-1)) |> ignore
  table.remove_rows(@tabular.Rows::first()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| c | f |
      #|+---+   +
      #|| e |   |
      #|+---+---+
      #|| g | h |
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
test "table vertical align center" {
  let table = @tabular.Table::from_rows([
    ["left\ncell", "right one"],
    ["the second column", "and\nhere\nsee\na"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.set_valign(@tabular.VAlign::center()) |> ignore
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
      #|---+----------+----------
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
  let expected = "=== ==========\n N   column 0 \n=== ==========\n 0     0-0    \n=== =========="
  assert_eq(table.to_string(), expected)
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
  let expected = "--------------\n N  column 0 \n 0    0-0    "
  assert_eq(table.to_string(), expected)
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
      #|-------------------------
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
test "modify segment align left" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
      #| 0 | 0-0      | 0-1      
      #| 1 | 1-0      | 1-1      
    ),
  )
}

///|
test "modify rows align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.modify_rows(
    @tabular.Rows::first(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::new(1, 3),
    @tabular.Setting::align(@tabular.Align::right()),
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
test "modify columns vertical align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "E\nnde\navou\nros", "0-1"],
    ["1", "Red\nHat", "https://\nwww\n.\nredhat\n.com\n/en"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::new(1, 3),
    @tabular.Setting::valign(@tabular.VAlign::bottom()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
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
      #|---+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::all().skip(1).step_by(2),
    @tabular.Setting::align(@tabular.Align::right()),
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::one(2),
    @tabular.Setting::align(@tabular.Align::right()),
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
      #| 0 |   0-0    |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "modify cell align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(
    @tabular.Cell::new(1, 1),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
      #| 0 |      0-0 |   0-1    
      #| 1 |   1-0    |   1-1    
    ),
  )
}

///|
test "modify last row align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::last(),
    @tabular.Setting::align(@tabular.Align::right()),
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
test "modify last column align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_columns(
    @tabular.Columns::last(),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::last_offset(1),
    @tabular.Setting::align(@tabular.Align::right()),
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
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
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1).and_columns(@tabular.Columns::one(2)),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1).and_(@tabular.Rows::one(3)),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1).not_columns(@tabular.Columns::one(1)),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Columns::one(2).not_rows(@tabular.Rows::first()),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_segment(
    @tabular.Rows::one(1)
    .as_segment()
    .and_(@tabular.Columns::one(2).as_segment())
    .not_(@tabular.Cell::new(1, 2).as_segment()),
    @tabular.Setting::align(@tabular.Align::right()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
      #|-------+-------
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
      #|---+-------
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
      #|-------+--------------+--------------
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
      #|---+----------+----------+----------
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
      #|---+--------------+--------------+--------------
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
      #|-------+--------------+--------------+--------------
      #| (x) 0 |     0-0      |     0-1      |     0-2      
      #| (x) 1 |     1-0      |     1-1      |     1-2      
      #| (x) 2 |     2-0      |     2-1      |     2-2      
    ),
  )
}

///|
test "format content keeps padding and align" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
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
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N |   column 0   | column 1 
      #|---+--------------+----------
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
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 
      #|---+----------+----------
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
      #|---+-----+-----
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
      #|----------+----------
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
      #|---+----------+----------
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
    @tabular.Setting::align(@tabular.Align::left()),
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

///|
test "cell column span at header row col 0" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N       | column 1 | column 2 
      #|---+-----+----------+----------
      #| 0 | 0-0 | 0-1      | 0-2      
      #| 1 | 1-0 | 1-1      | 1-2      
      #| 2 | 2-0 | 2-1      | 2-2      
    ),
  )
}

///|
test "cell column span at data row 0 col 0" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0            | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell column span at data row 1 col 0 center" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #|      1       |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "cell column span at data row 2 col 0" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 0), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2            | 2-1      | 2-2      
    ),
  )
}

///|
test "cell column span at header row col 1" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 1), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0  | column 2 
      #|---+-----+-----+----------
      #| 0 | 0-0 | 0-1 | 0-2      
      #| 1 | 1-0 | 1-1 | 1-2      
      #| 2 | 2-0 | 2-1 | 2-2      
    ),
  )
}

///|
test "cell column span at data row 1 col 1" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0                 | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell column span at data row 2 col 1" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 1), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0                 | 2-2      
    ),
  )
}

///|
test "cell column span at header row col 2 center" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1  
      #|---+----------+-----+-----
      #| 0 |   0-0    | 0-1 | 0-2 
      #| 1 |   1-0    | 1-1 | 1-2 
      #| 2 |   2-0    | 2-1 | 2-2 
    ),
  )
}

///|
test "cell column span at data row 0 col 2 center" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |         0-1         
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "cell column span at data row 1 col 2 center" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(2, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |         1-1         
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "cell column span at data row 2 col 2 center" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |         2-1         
    ),
  )
}

///|
test "column span on whole column col 0" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_columns(@tabular.Columns::one(0), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 1 | column 2 
      #|+--+----------+----------
      #| 0 | 0-1      | 0-2      
      #| 1 | 1-1      | 1-2      
      #| 2 | 2-1      | 2-2      
    ),
  )
}

///|
test "column span on column range 1" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_columns(@tabular.Columns::new(1, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 2 
      #|---++---------+----------
      #| 0 | 0-0      | 0-2      
      #| 1 | 1-0      | 1-2      
      #| 2 | 2-0      | 2-2      
    ),
  )
}

///|
test "column span covers full row" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_columns(@tabular.Columns::one(0), @tabular.Span::column(4))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N 
      #|+++
      #| 0 
      #| 1 
      #| 2 
    ),
  )
}

///|
test "column span bigger than max" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::column(100))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+-----+-----+
      #||          N          |
      #|+---+-----+-----+-----+
      #|| 0 | 0-0 | 0-1 | 0-2 |
      #|+---+-----+-----+-----+
      #|| 1 | 1-0 | 1-1 | 1-2 |
      #|+---+-----+-----+-----+
      #|| 2 | 2-0 | 2-1 | 2-2 |
      #|+---+-----+-----+-----+
    ),
  )
}

///|
test "column span multiline content" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "https://\nwww\n.\nredhat\n.com\n/en", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |      https://       
      #|   |          |         www         
      #|   |          |          .          
      #|   |          |       redhat        
      #|   |          |        .com         
      #|   |          |         /en         
    ),
  )
}

///|
test "padding works in spanned columns" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::padding(@tabular.Padding::new(3, 0, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(3))
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 1), @tabular.Span::column(3))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|   N|   column 0|   column 1|   column 2
      #|----+-----------+-----------+-----------
      #|   0|   0-0                             
      #|   1|   1-0     |   1-1     |   1-2     
      #|   2|   2-0                             
    ),
  )
}

///|
test "column span multiple negatives" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::column(-1))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 3), @tabular.Span::column(-2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 3), @tabular.Span::column(-100))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #|| 0 |         0-1         |   0-2    |
      #|+---+----------+----------+----------+
      #|| 1 |              1-2               |
      #|+---+----------+----------+----------+
      #||                2-2                 |
      #|+---+----------+----------+----------+
    ),
  )
}

///|
test "column span multiple zeros" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::column(0))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 3), @tabular.Span::column(0))
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 3), @tabular.Span::column(0))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #||                0-1                 |
      #|+---+----------+----------+----------+
      #||                1-2                 |
      #|+---+----------+----------+----------+
      #||                2-2                 |
      #|+---+----------+----------+----------+
    ),
  )
}

// ──────────────────────────────────────────────────
// Row-span cell position tests ported from upstream cell_span_test
// ──────────────────────────────────────────────────

///|
test "cell row span (0,0) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|   +----------+----------+----------
      #|   | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (1,0) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #|   | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (2,0) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #|   |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "cell row span (0,1) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 1), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+          +----------+----------
      #| 0 |          | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (0,2) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 2), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+          +----------
      #| 0 | 0-0      |          | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (0,3) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 3), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+          
      #| 0 |   0-0    |   0-1    |          
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "cell row span (1,1) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 |          | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (2,1) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 |          | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (1,2) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 2), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      |          | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (2,2) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 2), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      |          | 2-2      
    ),
  )
}

///|
test "cell row span (1,3) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 3), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      |          
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "cell row span (2,3) psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 3), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      |          
    ),
  )
}

// ──────────────────────────────────────────────────
// Whole-row row span tests ported from upstream span_row_test
// ──────────────────────────────────────────────────

///|
test "whole row span header row ascii" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(@tabular.Rows::one(0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|+ N + column 0 + column 1 + column 2 +
      #|+---+----------+----------+----------+
      #|| 1 | 1-0      | 1-1      | 1-2      |
      #|+---+----------+----------+----------+
      #|| 2 | 2-0      | 2-1      | 2-2      |
      #|+---+----------+----------+----------+
    ),
  )
}

///|
test "whole row span header row psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(@tabular.Rows::one(0), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N + column 0 + column 1 + column 2 
      #| 1 | 1-0      | 1-1      | 1-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "whole row span data row 1 psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(@tabular.Rows::new(1, 2), @tabular.Span::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 | 0-0      | 0-1      | 0-2      
      #| 2 | 2-0      | 2-1      | 2-2      
    ),
  )
}

///|
test "whole row span full table psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_rows(@tabular.Rows::one(0), @tabular.Span::row(4)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N + column 0 + column 1 + column 2 
    ),
  )
}

// ──────────────────────────────────────────────────
// Multiline + padding + collision span tests
// ──────────────────────────────────────────────────

///|
test "span multiline content in column span" {
  // Upstream span_multiline: multiline content in spanned column
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "https://\nwww\n.\nredhat\n.com\n/en", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 2), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |      https://       
      #|   |          |         www         
      #|   |          |          .          
      #|   |          |       redhat        
      #|   |          |        .com         
      #|   |          |         /en         
    ),
  )
}

///|
test "padding works in spanned columns psql" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::padding(@tabular.Padding::new(3, 0, 0, 0)),
  )
  |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(3))
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 1), @tabular.Span::column(3))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|   N|   column 0|   column 1|   column 2
      #|----+-----------+-----------+-----------
      #|   0|   0-0                             
      #|   1|   1-0     |   1-1     |   1-2     
      #|   2|   2-0                             
    ),
  )
}

///|
test "spanned columns with collision modern" {
  // Upstream spaned_columns_with_collision: all cells are "just 1 column"
  let data = [
    ["0", "1", "2", "3", "4"],
    [
      "just 1 column", "just 1 column", "just 1 column", "just 1 column", "just 1 column",
    ],
    [
      "just 1 column", "just 1 column", "just 1 column", "just 1 column", "just 1 column",
    ],
    [
      "just 1 column", "just 1 column", "just 1 column", "just 1 column", "just 1 column",
    ],
    [
      "just 1 column", "just 1 column", "just 1 column", "just 1 column", "just 1 column",
    ],
    [
      "just 1 column", "just 1 column", "just 1 column", "just 1 column", "just 1 column",
    ],
  ]
  let table = @tabular.Table::from_rows(data)
  table.apply(@tabular.Style::modern()) |> ignore
  // (0,0) span 5 columns with content override
  table.modify_cell(
    @tabular.Cell::new(0, 0),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span all 5 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::column(5))
  |> ignore
  // (1,0) span 4 columns with content override
  table.modify_cell(
    @tabular.Cell::new(1, 0),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span 4 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::column(4))
  |> ignore
  // (2,0) span 3 columns
  table.modify_cell(
    @tabular.Cell::new(2, 0),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span 3 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::column(3))
  |> ignore
  // (2,3) span 2 columns
  table.modify_cell(
    @tabular.Cell::new(2, 3),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span 2 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 3), @tabular.Span::column(2))
  |> ignore
  // (3,0) span 2 columns
  table.modify_cell(
    @tabular.Cell::new(3, 0),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span 3 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 0), @tabular.Span::column(2))
  |> ignore
  // (3,2) span 3 columns
  table.modify_cell(
    @tabular.Cell::new(3, 2),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span 3 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 2), @tabular.Span::column(3))
  |> ignore
  // (4,1) span 4 columns
  table.modify_cell(
    @tabular.Cell::new(4, 1),
    @tabular.Setting::format(
      @tabular.Format::content(fn(_s) { "span 4 columns" }),
    ),
  )
  |> ignore
  table.modify_cell(@tabular.Cell::new(4, 1), @tabular.Span::column(4))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐
      #|│                              span all 5 columns                               │
      #|├───────────────┼───────────────┼───────────────┼───────────────┼───────────────┤
      #|│                        span 4 columns                         │ just 1 column │
      #|├───────────────┼───────────────┼───────────────┼───────────────┼───────────────┤
      #|│                span 3 columns                 │        span 2 columns         │
      #|├───────────────┼───────────────┼───────────────┼───────────────┼───────────────┤
      #|│        span 3 columns         │                span 3 columns                 │
      #|├───────────────┼───────────────┼───────────────┼───────────────┼───────────────┤
      #|│ just 1 column │                        span 4 columns                         │
      #|├───────────────┼───────────────┼───────────────┼───────────────┼───────────────┤
      #|│ just 1 column │ just 1 column │ just 1 column │ just 1 column │ just 1 column │
      #|└───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘
    ),
  )
}

// ──────────────────────────────────────────────────
// Upstream span_row_negative_0 / span_row_zero_0
// ──────────────────────────────────────────────────

///|
test "row span multiple negatives" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::row(-1)) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 2), @tabular.Span::row(-2)) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 3), @tabular.Span::row(-100))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+-----+
      #|| N | column 0 | column 1 | 2-2 |
      #|+---+----------+----------+     +
      #|| 0 |   1-0    |   2-1    |     |
      #|+---+          +          +     +
      #|| 1 |          |          |     |
      #|+---+----------+          +     +
      #|| 2 |   2-0    |          |     |
      #|+---+----------+----------+-----+
    ),
  )
}

///|
test "row span multiple zeros" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(2, 1), @tabular.Span::row(0)) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 2), @tabular.Span::row(0)) |> ignore
  table.modify_cell(@tabular.Cell::new(3, 3), @tabular.Span::row(0)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+-----+-----+
      #|| N | 1-0 | 2-1 | 2-2 |
      #|+---+     +     +     +
      #|| 0 |     |     |     |
      #|+---+     +     +     +
      #|| 1 |     |     |     |
      #|+---+     +     +     +
      #|| 2 |     |     |     |
      #|+---+-----+-----+-----+
    ),
  )
}

// ──────────────────────────────────────────────────
// Upstream column span invalid position tests
// ──────────────────────────────────────────────────

///|
test "column span invalid position row" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(1000, 0), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #|| 0 |   0-0    |   0-1    |   0-2    |
      #|+---+----------+----------+----------+
      #|| 1 |   1-0    |   1-1    |   1-2    |
      #|+---+----------+----------+----------+
      #|| 2 |   2-0    |   2-1    |   2-2    |
      #|+---+----------+----------+----------+
    ),
  )
}

///|
test "column span invalid position column" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(0, 1000), @tabular.Span::column(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #|| 0 |   0-0    |   0-1    |   0-2    |
      #|+---+----------+----------+----------+
      #|| 1 |   1-0    |   1-1    |   1-2    |
      #|+---+----------+----------+----------+
      #|| 2 |   2-0    |   2-1    |   2-2    |
      #|+---+----------+----------+----------+
    ),
  )
}

///|
test "row span invalid position column" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(0, 1000), @tabular.Span::row(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #|| 0 |   0-0    |   0-1    |   0-2    |
      #|+---+----------+----------+----------+
      #|| 1 |   1-0    |   1-1    |   1-2    |
      #|+---+----------+----------+----------+
      #|| 2 |   2-0    |   2-1    |   2-2    |
      #|+---+----------+----------+----------+
    ),
  )
}

///|
test "row span invalid position both" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_cell(@tabular.Cell::new(1000, 1000), @tabular.Span::row(2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+----------+
      #|| N | column 0 | column 1 | column 2 |
      #|+---+----------+----------+----------+
      #|| 0 |   0-0    |   0-1    |   0-2    |
      #|+---+----------+----------+----------+
      #|| 1 |   1-0    |   1-1    |   1-2    |
      #|+---+----------+----------+----------+
      #|| 2 |   2-0    |   2-1    |   2-2    |
      #|+---+----------+----------+----------+
    ),
  )
}

// ──────────────────────────────────────────────────
// Upstream panel_test.rs
// ──────────────────────────────────────────────────

///|
fn matrix33() -> @tabular.Table {
  @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
}

///|
test "panel_has_no_style_by_default" {
  let table = matrix33()
  table.panel(@tabular.Panel::horizontal(0, "Linux Distributions")) |> ignore
  table.apply(@tabular.Style::psql()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|        Linux Distributions         
      #|---+----------+----------+----------
      #| N | column 0 | column 1 | column 2 
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "top_panel" {
  let table = matrix33()
  table.panel(@tabular.Panel::horizontal(0, "Linux Distributions")) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  table.apply(@tabular.Style::psql()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|        Linux Distributions         
      #|---+----------+----------+----------
      #| N | column 0 | column 1 | column 2 
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "bottom_panel" {
  let table = matrix33()
  table.panel(@tabular.Panel::horizontal(4, "Linux Distributions")) |> ignore
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  table.apply(@tabular.Style::psql()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
      #|        Linux Distributions         
    ),
  )
}

///|
test "inner_panel" {
  let table = matrix33()
  table.panel(@tabular.Panel::horizontal(2, "Linux Distributions")) |> ignore
  table.modify_rows(
    @tabular.Rows::new(2, -1),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  table.apply(@tabular.Style::psql()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 
      #|---+----------+----------+----------
      #| 0 |   0-0    |   0-1    |   0-2    
      #|        Linux Distributions         
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "panel_header" {
  let table = matrix33()
  table.panel(@tabular.Panel::header("Linux Distributions")) |> ignore
  table.apply(@tabular.Style::psql()) |> ignore
  table.modify_rows(
    @tabular.Rows::new(0, 1),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|        Linux Distributions         
      #|---+----------+----------+----------
      #| N | column 0 | column 1 | column 2 
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "panel_footer" {
  let table = matrix33()
  table.panel(@tabular.Panel::header("Linux Distributions")) |> ignore
  table.panel(@tabular.Panel::footer("The end")) |> ignore
  table.apply(@tabular.Style::psql()) |> ignore
  // Center first and last rows
  table.modify_rows(
    @tabular.Rows::one(0),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  table.modify_rows(
    @tabular.Rows::last(),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|        Linux Distributions         
      #|---+----------+----------+----------
      #| N | column 0 | column 1 | column 2 
      #| 0 |   0-0    |   0-1    |   0-2    
      #| 1 |   1-0    |   1-1    |   1-2    
      #| 2 |   2-0    |   2-1    |   2-2    
      #|              The end               
    ),
  )
}

///|
test "panel_style_uses_most_left_and_right_cell_styles" {
  let table = @tabular.Table::from_rows([["i32", "i32"], ["0", "1"]])
  table.panel(@tabular.Panel::horizontal(0, "Numbers")) |> ignore
  table.apply(@tabular.Style::modern()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌─────┬─────┐
      #|│  Numbers  │
      #|├─────┼─────┤
      #|│ i32 │ i32 │
      #|├─────┼─────┤
      #|│  0  │  1  │
      #|└─────┴─────┘
    ),
  )
}

///|
test "panel_in_single_column" {
  let table = @tabular.Table::from_rows([["i32"], ["0"]])
  table.panel(@tabular.Panel::horizontal(0, "Numbers")) |> ignore
  table.apply(@tabular.Style::modern()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌─────────┐
      #|│ Numbers │
      #|├─────────┤
      #|│   i32   │
      #|├─────────┤
      #|│    0    │
      #|└─────────┘
    ),
  )
}

///|
test "panel_vertical_0" {
  let table = matrix33()
  table.apply(@tabular.Style::psql()) |> ignore
  table.panel(@tabular.Panel::vertical(0, "Linux Distributions")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| Linux Distributions | N | column 0 | column 1 | column 2 
      #|                     +---+----------+----------+----------
      #|                     | 0 |   0-0    |   0-1    |   0-2    
      #|                     | 1 |   1-0    |   1-1    |   1-2    
      #|                     | 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "panel_vertical_1" {
  let table = matrix33()
  table.apply(@tabular.Style::psql()) |> ignore
  table.panel(@tabular.Panel::vertical(1, "Linux Distributions")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | Linux Distributions | column 0 | column 1 | column 2 
      #|---+                     +----------+----------+----------
      #| 0 |                     |   0-0    |   0-1    |   0-2    
      #| 1 |                     |   1-0    |   1-1    |   1-2    
      #| 2 |                     |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "panel_vertical_2" {
  let table = matrix33()
  table.apply(@tabular.Style::psql()) |> ignore
  table.panel(@tabular.Panel::vertical(4, "Linux Distributions")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| N | column 0 | column 1 | column 2 | Linux Distributions 
      #|---+----------+----------+----------+                     
      #| 0 |   0-0    |   0-1    |   0-2    |                     
      #| 1 |   1-0    |   1-1    |   1-2    |                     
      #| 2 |   2-0    |   2-1    |   2-2    |                     
    ),
  )
}

///|
test "panel_horizontal_set_0" {
  let table = matrix33()
  table.apply(@tabular.Style::psql()) |> ignore
  table.panel(@tabular.Panel::horizontal(0, "Linux Distributions")) |> ignore
  table.panel(@tabular.Panel::vertical(0, "asd")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| asd |        Linux Distributions         
      #|     +---+----------+----------+----------
      #|     | N | column 0 | column 1 | column 2 
      #|     | 0 |   0-0    |   0-1    |   0-2    
      #|     | 1 |   1-0    |   1-1    |   1-2    
      #|     | 2 |   2-0    |   2-1    |   2-2    
    ),
  )
}

///|
test "panel_horizontal_set_1" {
  let table = matrix33()
  table.apply(@tabular.Style::psql()) |> ignore
  table.panel(@tabular.Panel::horizontal(0, "Linux Distributions")) |> ignore
  table.panel(@tabular.Panel::vertical(0, "asd")) |> ignore
  table.panel(@tabular.Panel::vertical(5, "asd")) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| asd |        Linux Distributions         | asd 
      #|     +---+----------+----------+----------+     
      #|     | N | column 0 | column 1 | column 2 |     
      #|     | 0 |   0-0    |   0-1    |   0-2    |     
      #|     | 1 |   1-0    |   1-1    |   1-2    |     
      #|     | 2 |   2-0    |   2-1    |   2-2    |     
    ),
  )
}

// ──────────────────────────────────────────────────
// Upstream merge_test.rs
// ──────────────────────────────────────────────────

///|
test "merge_horizontal" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "1", "1"],
    ["1", "1", "2"],
    ["1", "1", "1"],
  ])
  table.merge(@tabular.Merge::horizontal()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+---+
      #|| 0 |   1   |
      #|+---+---+---+
      #||   1   | 2 |
      #|+---+---+---+
      #||     1     |
      #|+---+---+---+
    ),
  )
}

///|
test "merge_horizontal_with_no_duplicates" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "1", "2"],
    ["0", "1", "2"],
    ["0", "1", "2"],
  ])
  table.merge(@tabular.Merge::horizontal()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+---+
    ),
  )
}

///|
test "merge_horizontal_empty" {
  let table = @tabular.Table::from_rows([])
  table.merge(@tabular.Merge::horizontal()) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "merge_vertical_0" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "3", "5"],
    ["0", "3", "3"],
    ["0", "2", "3"],
  ])
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+   +---+---+
      #||   | 3 | 5 |
      #|+   +   +---+
      #|+   +---+ 3 +
      #||   | 2 |   |
      #|+---+---+---+
    ),
  )
}

///|
test "merge_vertical_1" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "3", "2"],
    ["0", "3", "3"],
    ["0", "2", "3"],
  ])
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+   +---+   +
      #|+   + 3 +---+
      #|+   +---+ 3 +
      #||   | 2 |   |
      #|+---+---+---+
    ),
  )
}

///|
test "merge_vertical_with_no_duplicates" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["5", "5", "5"],
    ["15", "15", "15"],
    ["115", "115", "115"],
  ])
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+-----+
      #||  0  |  1  |  2  |
      #|+-----+-----+-----+
      #||  5  |  5  |  5  |
      #|+-----+-----+-----+
      #|| 15  | 15  | 15  |
      #|+-----+-----+-----+
      #|| 115 | 115 | 115 |
      #|+-----+-----+-----+
    ),
  )
}

///|
test "merge_vertical_empty" {
  let table = @tabular.Table::from_rows([])
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "merge_horizontal_and_vertical_0" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["3", "3", "5"],
    ["3", "7", "8"],
    ["9", "10", "11"],
  ])
  table.merge(@tabular.Merge::horizontal()) |> ignore
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----+----+
      #|| 0 | 1  | 2  |
      #|+---+----+----+
      #||   3    | 5  |
      #|+---+----+----+
      #|| 3 | 7  | 8  |
      #|+---+----+----+
      #|| 9 | 10 | 11 |
      #|+---+----+----+
    ),
  )
}

///|
test "merge_horizontal_and_vertical_1" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "1", "1"],
    ["1", "1", "2"],
    ["1", "1", "1"],
  ])
  table.merge(@tabular.Merge::horizontal()) |> ignore
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+   +---+---+
      #||   |   1   |
      #|+---+---+---+
      #||   1   | 2 |
      #|+---+---+---+
      #||     1     |
      #|+---+---+---+
    ),
  )
}

///|
test "merge_horizontal_and_vertical_7" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["0", "0", "0"],
    ["0", "0", "1"],
    ["2", "0", "0"],
  ])
  table.merge(@tabular.Merge::horizontal()) |> ignore
  table.merge(@tabular.Merge::vertical()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+---+
      #||     0     |
      #|+---+---+---+
      #||   0   | 1 |
      #|+---+---+---+
      #|| 2 |   0   |
      #|+---+---+---+
    ),
  )
}

///|
test "merge_vertical_then_horizontal_3" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["3", "4", "5"],
    ["3", "3", "8"],
    ["3", "10", "11"],
  ])
  table.merge(@tabular.Merge::vertical()) |> ignore
  table.merge(@tabular.Merge::horizontal()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----+----+
      #|| 0 | 1  | 2  |
      #|+---+----+----+
      #|| 3 | 4  | 5  |
      #|+   +----+----+
      #||   | 3  | 8  |
      #|+   +----+----+
      #||   | 10 | 11 |
      #|+---+----+----+
    ),
  )
}

///|
test "merge_vertical_then_horizontal_4" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["3", "4", "5"],
    ["4", "4", "8"],
    ["3", "4", "11"],
  ])
  table.merge(@tabular.Merge::vertical()) |> ignore
  table.merge(@tabular.Merge::horizontal()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+----+
      #|| 0 | 1 | 2  |
      #|+---+---+----+
      #|| 3 | 4 | 5  |
      #|+---+   +----+
      #|| 4 |   | 8  |
      #|+---+   +----+
      #|| 3 |   | 11 |
      #|+---+---+----+
    ),
  )
}

///|
fn matrix_n_cols(rows : Int, cols : Int) -> @tabular.Table {
  let data = []
  let header = []
  for c = 0; c < cols; c = c + 1 {
    header.push("column \{c}")
  }
  data.push(["N"] + header)
  for r = 0; r < rows; r = r + 1 {
    let row = [r.to_string()]
    for c = 0; c < cols; c = c + 1 {
      row.push("\{r}-\{c}")
    }
    data.push(row)
  }
  @tabular.Table::from_rows(data)
}

///|
test "highlingt_object_exceeds_boundaries" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_cell(@tabular.Cell::new(1000, 0), '+'),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │ column 2 │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 0 │   0-0    │   0-1    │   0-2    │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 1 │   1-0    │   1-1    │   1-2    │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 2 │   2-0    │   2-1    │   2-2    │
      #|└───┴──────────┴──────────┴──────────┘
    ),
  )
}

///|
test "highlingt_empty_table" {
  let table = @tabular.Table::from_rows([])
  table.highlight(
    @tabular.Highlight::outline_segment(@tabular.Segment::all(), '+'),
  )
  |> ignore
  inspect(table.to_string(), content="")
}

///|
test "highlingt_cell" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_cell(@tabular.Cell::new(0, 0), '+'),
  )
  |> ignore
  table.highlight(
    @tabular.Highlight::outline_cell(@tabular.Cell::new(1, 1), '*'),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+++++──────────┬──────────┬──────────┐
      #|+ N + column 0 │ column 1 │ column 2 │
      #|++++************──────────┼──────────┤
      #|│ 0 *   0-0    *   0-1    │   0-2    │
      #|├───************──────────┼──────────┤
      #|│ 1 │   1-0    │   1-1    │   1-2    │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 2 │   2-0    │   2-1    │   2-2    │
      #|└───┴──────────┴──────────┴──────────┘
    ),
  )
}

///|
test "highlingt_row" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(@tabular.Highlight::outline_rows(@tabular.Rows::one(0), '+'))
  |> ignore
  table.highlight(@tabular.Highlight::outline_rows(@tabular.Rows::one(3), '*'))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|++++++++++++++++++++++++++++++++++++++
      #|+ N │ column 0 │ column 1 │ column 2 +
      #|++++++++++++++++++++++++++++++++++++++
      #|│ 0 │   0-0    │   0-1    │   0-2    │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 1 │   1-0    │   1-1    │   1-2    │
      #|**************************************
      #|* 2 │   2-0    │   2-1    │   2-2    *
      #|**************************************
    ),
  )
}

///|
test "highlingt_column" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::new_columns(@tabular.Columns::one(0)).with_border(
      @papergrid.CellBorder::filled('+'),
    ),
  )
  |> ignore
  table.highlight(
    @tabular.Highlight::new_columns(@tabular.Columns::one(2)).with_border(
      @papergrid.CellBorder::filled('*'),
    ),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+++++──────────************──────────┐
      #|+ N + column 0 * column 1 * column 2 │
      #|+───+──────────*──────────*──────────┤
      #|+ 0 +   0-0    *   0-1    *   0-2    │
      #|+───+──────────*──────────*──────────┤
      #|+ 1 +   1-0    *   1-1    *   1-2    │
      #|+───+──────────*──────────*──────────┤
      #|+ 2 +   2-0    *   2-1    *   2-2    │
      #|+++++──────────************──────────┘
    ),
  )
}

///|
test "highlingt_row_range" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_rows(@tabular.Rows::new(1, 3), '+'),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │ column 2 │
      #|++++++++++++++++++++++++++++++++++++++
      #|+ 0 │   0-0    │   0-1    │   0-2    +
      #|+───┼──────────┼──────────┼──────────+
      #|+ 1 │   1-0    │   1-1    │   1-2    +
      #|++++++++++++++++++++++++++++++++++++++
      #|│ 2 │   2-0    │   2-1    │   2-2    │
      #|└───┴──────────┴──────────┴──────────┘
    ),
  )
}

///|
test "highlingt_column_range" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_columns(@tabular.Columns::new(0, 2), '+'),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|++++++++++++++++──────────┬──────────┐
      #|+ N │ column 0 + column 1 │ column 2 │
      #|+───┼──────────+──────────┼──────────┤
      #|+ 0 │   0-0    +   0-1    │   0-2    │
      #|+───┼──────────+──────────┼──────────┤
      #|+ 1 │   1-0    +   1-1    │   1-2    │
      #|+───┼──────────+──────────┼──────────┤
      #|+ 2 │   2-0    +   2-1    │   2-2    │
      #|++++++++++++++++──────────┴──────────┘
    ),
  )
}

///|
test "highlingt_frame" {
  let border : @papergrid.CellBorder = {
    top: Some('+'),
    bottom: Some('+'),
    left: Some('+'),
    right: Some('+'),
    left_top_corner: Some('*'),
    right_top_corner: Some('#'),
    left_bottom_corner: Some('@'),
    right_bottom_corner: Some('.'),
  }
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_segment(@tabular.Segment::all(), '+').with_border(
      border,
    ),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|*++++++++++++++++++++++++++++++++++++#
      #|+ N │ column 0 │ column 1 │ column 2 +
      #|+───┼──────────┼──────────┼──────────+
      #|+ 0 │   0-0    │   0-1    │   0-2    +
      #|+───┼──────────┼──────────┼──────────+
      #|+ 1 │   1-0    │   1-1    │   1-2    +
      #|+───┼──────────┼──────────┼──────────+
      #|+ 2 │   2-0    │   2-1    │   2-2    +
      #|@++++++++++++++++++++++++++++++++++++.
    ),
  )
}

///|
test "highlingt_single_column" {
  let table = matrix_n_cols(3, 0)
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::new_cell(@tabular.Cell::new(0, 0)).with_border({
      ..@papergrid.CellBorder::empty(),
      left: Some('*'),
      top: Some('x'),
    }),
  )
  |> ignore
  table.highlight(
    @tabular.Highlight::new_rows(@tabular.Rows::new(1, 3)).with_border({
      ..@papergrid.CellBorder::empty(),
      left: Some('n'),
    }),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌xxx┐
      #|* N │
      #|├───┤
      #|n 0 │
      #|n───┤
      #|n 1 │
      #|├───┤
      #|│ 2 │
      #|└───┘
    ),
  )
}

///|
test "highlingt_several_times" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_segment(@tabular.Segment::all(), '*'),
  )
  |> ignore
  table.highlight(
    @tabular.Highlight::outline_cell(@tabular.Cell::new(1, 1), '#'),
  )
  |> ignore
  table.highlight(
    @tabular.Highlight::outline_columns(@tabular.Columns::one(3), 'x'),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|**************************xxxxxxxxxxxx
      #|* N │ column 0 │ column 1 x column 2 x
      #|*───############──────────x──────────x
      #|* 0 #   0-0    #   0-1    x   0-2    x
      #|*───############──────────x──────────x
      #|* 1 │   1-0    │   1-1    x   1-2    x
      #|*───┼──────────┼──────────x──────────x
      #|* 2 │   2-0    │   2-1    x   2-2    x
      #|**************************xxxxxxxxxxxx
    ),
  )
}

///|
test "highlingt_complex_figures_corners" {
  let border : @papergrid.CellBorder = {
    top: Some('+'),
    bottom: Some('+'),
    left: Some('+'),
    right: Some('+'),
    left_top_corner: Some('*'),
    right_top_corner: Some('#'),
    left_bottom_corner: Some('@'),
    right_bottom_corner: Some('.'),
  }
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.highlight(
    @tabular.Highlight::outline_segment(
      @tabular.Cell::new(0, 0)
      .as_segment()
      .and_cell(@tabular.Cell::new(3, 3))
      .and_cell(@tabular.Cell::new(0, 3))
      .and_cell(@tabular.Cell::new(3, 0)),
      '+',
    ).with_border(border),
  )
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|*+++#──────────┬──────────*++++++++++#
      #|+ N + column 0 │ column 1 + column 2 +
      #|@+++.──────────┼──────────@++++++++++.
      #|│ 0 │   0-0    │   0-1    │   0-2    │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 1 │   1-0    │   1-1    │   1-2    │
      #|*+++#──────────┼──────────*++++++++++#
      #|+ 2 +   2-0    │   2-1    +   2-2    +
      #|@+++.──────────┴──────────@++++++++++.
    ),
  )
}

///|
test "highlingt_complex_rows_and_columns" {
  let border : @papergrid.CellBorder = {
    top: Some('+'),
    bottom: Some('+'),
    left: Some('+'),
    right: Some('+'),
    left_top_corner: Some('*'),
    right_top_corner: Some('#'),
    left_bottom_corner: Some('@'),
    right_bottom_corner: Some('.'),
  }
  let table1 = matrix33()
  table1.apply(@tabular.Style::modern()) |> ignore
  table1.highlight(
    @tabular.Highlight::outline_rows(@tabular.Rows::one(0), '+').with_border(
      border,
    ),
  )
  |> ignore
  table1.highlight(
    @tabular.Highlight::outline_rows(@tabular.Rows::one(3), '+').with_border(
      border,
    ),
  )
  |> ignore
  inspect(
    table1.to_string(),
    content=(
      #|*++++++++++++++++++++++++++++++++++++#
      #|+ N │ column 0 │ column 1 │ column 2 +
      #|@++++++++++++++++++++++++++++++++++++.
      #|│ 0 │   0-0    │   0-1    │   0-2    │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 1 │   1-0    │   1-1    │   1-2    │
      #|*++++++++++++++++++++++++++++++++++++#
      #|+ 2 │   2-0    │   2-1    │   2-2    +
      #|@++++++++++++++++++++++++++++++++++++.
    ),
  )
  let table2 = matrix33()
  table2.apply(@tabular.Style::modern()) |> ignore
  table2.highlight(
    @tabular.Highlight::outline_columns(@tabular.Columns::one(0), '+').with_border(
      border,
    ),
  )
  |> ignore
  table2.highlight(
    @tabular.Highlight::outline_columns(@tabular.Columns::one(3), '+').with_border(
      border,
    ),
  )
  |> ignore
  inspect(
    table2.to_string(),
    content=(
      #|*+++#──────────┬──────────*++++++++++#
      #|+ N + column 0 │ column 1 + column 2 +
      #|+───+──────────┼──────────+──────────+
      #|+ 0 +   0-0    │   0-1    +   0-2    +
      #|+───+──────────┼──────────+──────────+
      #|+ 1 +   1-0    │   1-1    +   1-2    +
      #|+───+──────────┼──────────+──────────+
      #|+ 2 +   2-0    │   2-1    +   2-2    +
      #|@+++.──────────┴──────────@++++++++++.
    ),
  )
}

///|
fn shadow_matrix() -> @tabular.Table {
  @tabular.Table::from_rows([
    ["i32", "i32", "i32"],
    ["123", "456", "789"],
    ["234", "567", "891"],
  ])
}

///|
test "shadow_bottom_right" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::psql()) |> ignore
  table.shadow(@tabular.Shadow::new(1)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| i32 | i32 | i32  
      #|-----+-----+-----▒
      #| 123 | 456 | 789 ▒
      #| 234 | 567 | 891 ▒
      #| ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
    ),
  )
}

///|
test "shadow_bottom_left" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::psql()) |> ignore
  table.shadow(@tabular.Shadow::new(1).set_left()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|  i32 | i32 | i32 
      #|▒-----+-----+-----
      #|▒ 123 | 456 | 789 
      #|▒ 234 | 567 | 891 
      #| ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
    ),
  )
}

///|
test "shadow_top_right" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::psql()) |> ignore
  table.shadow(@tabular.Shadow::new(1).set_top()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
      #| i32 | i32 | i32  
      #|-----+-----+-----▒
      #| 123 | 456 | 789 ▒
      #| 234 | 567 | 891 ▒
    ),
  )
}

///|
test "shadow_top_left" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::psql()) |> ignore
  table.shadow(@tabular.Shadow::new(1).set_top().set_left()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #| ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
      #|  i32 | i32 | i32 
      #|▒-----+-----+-----
      #|▒ 123 | 456 | 789 
      #|▒ 234 | 567 | 891 
    ),
  )
}

///|
test "shadow_set_fill" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.shadow(@tabular.Shadow::new(1).set_fill('#')) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+-----+ 
      #|| i32 | i32 | i32 |#
      #|+-----+-----+-----+#
      #|| 123 | 456 | 789 |#
      #|+-----+-----+-----+#
      #|| 234 | 567 | 891 |#
      #|+-----+-----+-----+#
      #| ###################
    ),
  )
}

///|
test "shadow_size_2" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.shadow(@tabular.Shadow::new(2).set_fill('#')) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+-----+  
      #|| i32 | i32 | i32 |##
      #|+-----+-----+-----+##
      #|| 123 | 456 | 789 |##
      #|+-----+-----+-----+##
      #|| 234 | 567 | 891 |##
      #|+-----+-----+-----+##
      #| ####################
      #| ####################
    ),
  )
}

///|
test "shadow_set_offset" {
  let table = shadow_matrix()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.shadow(@tabular.Shadow::new(2).set_fill('#').set_offset(3)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+-----+  
      #|| i32 | i32 | i32 |  
      #|+-----+-----+-----+  
      #|| 123 | 456 | 789 |##
      #|+-----+-----+-----+##
      #|| 234 | 567 | 891 |##
      #|+-----+-----+-----+##
      #|   ##################
      #|   ##################
    ),
  )
}

// Helper: create Matrix::table(6, 4) equivalent (7 rows x 5 cols with header+index, centered)

///|
fn matrix64() -> @tabular.Table {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2", "column 3"],
    ["0", "0-0", "0-1", "0-2", "0-3"],
    ["1", "1-0", "1-1", "1-2", "1-3"],
    ["2", "2-0", "2-1", "2-2", "2-3"],
    ["3", "3-0", "3-1", "3-2", "3-3"],
    ["4", "4-0", "4-1", "4-2", "4-3"],
    ["5", "5-0", "5-1", "5-2", "5-3"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::center()),
  )
  |> ignore
  table
}

///|
test "border_correction_column_span_with_panel" {
  let table = @tabular.Table::from_rows([["0", "1", "2"], ["1", "2", "3"]])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.panel(@tabular.Panel::header("Tabled Releases")) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::column(2))
  |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----------------+
      #|| Tabled Releases |
      #|+-------+---------+
      #||   0   |    2    |
      #|+---+---+---------+
      #|| 1 | 2 |    3    |
      #|+---+---+---------+
    ),
  )
}

///|
test "border_correction_column_span_with_panel_2" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["1", "2", "3"],
    ["4", "5", "6"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.panel(@tabular.Panel::header("Tabled Releases")) |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::column(2))
  |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----------------+
      #|| Tabled Releases |
      #|+---+---+---------+
      #|| 0 | 1 |    2    |
      #|+---+---+---------+
      #||   1   |    3    |
      #|+---+---+---------+
      #|| 4 | 5 |    6    |
      #|+---+---+---------+
    ),
  )
}

///|
test "border_correction_column_span_with_panel_3" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["1", "2", "3"],
    ["4", "5", "6"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.panel(@tabular.Panel::header("Tabled Releases")) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::column(2))
  |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----------------+
      #|| Tabled Releases |
      #|+-------+---------+
      #||   0   |    2    |
      #|+-------+---------+
      #||   1   |    3    |
      #|+---+---+---------+
      #|| 4 | 5 |    6    |
      #|+---+---+---------+
    ),
  )
}

///|
test "border_correction_row_span" {
  let table = @tabular.Table::from_rows([["0", "1", "2"], ["1", "2", "3"]])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::row(2)) |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #||   +---+---+
      #||   | 2 | 3 |
      #|+---+---+---+
    ),
  )
}

///|
test "border_correction_row_span_multi" {
  let table = @tabular.Table::from_rows([
    ["0", "1", "2"],
    ["1", "2", "3"],
    ["4", "5", "6"],
  ])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::row(2)) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 2), @tabular.Span::row(3)) |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 0 | 1 | 2 |
      #|+---+---+   |
      #|| 1 | 2 |   |
      #||   +---+   |
      #||   | 5 |   |
      #|+---+---+---+
    ),
  )
}

///|
test "border_correction_right_bottom_corner_0" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::column(3))
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 1), @tabular.Span::row(3)) |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │ column 2 │
      #|├───┼──────────┴──────────┴──────────┤
      #|│ 0 │              0-0               │
      #|├───┤                                │
      #|│ 1 │                                │
      #|├───┤                                │
      #|│ 2 │                                │
      #|└───┴────────────────────────────────┘
    ),
  )
}

///|
test "border_correction_right_bottom_corner_1" {
  let table = matrix33()
  table.apply(@tabular.Style::modern()) |> ignore
  table.modify_cell(@tabular.Cell::new(2, 2), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 2), @tabular.Span::row(2)) |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬──────────┬──────────┬──────────┐
      #|│ N │ column 0 │ column 1 │ column 2 │
      #|├───┼──────────┼──────────┼──────────┤
      #|│ 0 │   0-0    │   0-1    │   0-2    │
      #|├───┼──────────┼──────────┴──────────┤
      #|│ 1 │   1-0    │         1-1         │
      #|├───┼──────────┤                     │
      #|│ 2 │   2-0    │                     │
      #|└───┴──────────┴─────────────────────┘
    ),
  )
}

///|
test "span_correct_test_0" {
  let table = matrix64()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 3), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::column(3))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 3), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 0), @tabular.Span::column(5))
  |> ignore
  table.modify_cell(@tabular.Cell::new(4, 1), @tabular.Span::column(4))
  |> ignore
  table.modify_cell(@tabular.Cell::new(5, 0), @tabular.Span::column(5))
  |> ignore
  table.modify_cell(@tabular.Cell::new(6, 0), @tabular.Span::column(5))
  |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+----------+----------+-----------+
      #|| N | column 0 | column 1 | column 2  |
      #|+---+----------+----------+-----+-----+
      #||            0            | 0-2 | 0-3 |
      #|+--------------+----------+-----+-----+
      #||      1       |   1-1    |    1-2    |
      #|+--------------+----------+-----------+
      #||                  2                  |
      #|+---+---------------------------------+
      #|| 3 |               3-0               |
      #|+---+---------------------------------+
      #||                  4                  |
      #|+-------------------------------------+
      #||                  5                  |
      #|+-------------------------------------+
    ),
  )
}

///|
test "span_correct_test_1" {
  let table = matrix64()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.modify_cell(@tabular.Cell::new(0, 0), @tabular.Span::column(5))
  |> ignore
  table.modify_cell(@tabular.Cell::new(1, 0), @tabular.Span::column(3))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 0), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(2, 3), @tabular.Span::column(2))
  |> ignore
  table.modify_cell(@tabular.Cell::new(3, 0), @tabular.Span::column(5))
  |> ignore
  table.modify_cell(@tabular.Cell::new(4, 1), @tabular.Span::column(4))
  |> ignore
  table.modify_cell(@tabular.Cell::new(5, 0), @tabular.Span::column(5))
  |> ignore
  table.modify_cell(@tabular.Cell::new(6, 0), @tabular.Span::column(5))
  |> ignore
  table.correct_borders() |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+----------------------+
      #||          N           |
      #|+----------+-----+-----+
      #||    0     | 0-2 | 0-3 |
      #|+----+-----+-----+-----+
      #|| 1  | 1-1 |    1-2    |
      #|+----+-----+-----------+
      #||          2           |
      #|+---+------------------+
      #|| 3 |       3-0        |
      #|+---+------------------+
      #||          4           |
      #|+----------------------+
      #||          5           |
      #|+----------------------+
    ),
  )
}

///|
/// Helper: create a 1-row table with a..z (26 columns)
fn alpha_table() -> @tabular.Table {
  let row : Array[String] = [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
    "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  ]
  @tabular.Table::from_rows([row])
}

///|
test "split_column_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | g | h | i | j | k | l |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| m | n | o | p | q | r | s | t | u | v | w | x |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| y | z |   |   |   |   |   |   |   |   |   |   |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_column_2_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  table.split(@tabular.Split::column(4)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+
      #|| a | b | c | d |
      #|+---+---+---+---+
      #|| e | f | g | h |
      #|+---+---+---+---+
      #|| i | j | k | l |
      #|+---+---+---+---+
      #|| m | n | o | p |
      #|+---+---+---+---+
      #|| q | r | s | t |
      #|+---+---+---+---+
      #|| u | v | w | x |
      #|+---+---+---+---+
      #|| y | z |   |   |
      #|+---+---+---+---+
    ),
  )
}

///|
test "split_column_retain_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  table.split(@tabular.Split::column(4).retain()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+
      #|| a | b | c | d |
      #|+---+---+---+---+
      #|| e | f | g | h |
      #|+---+---+---+---+
      #|| i | j | k | l |
      #|+---+---+---+---+
      #|| m | n | o | p |
      #|+---+---+---+---+
      #|| q | r | s | t |
      #|+---+---+---+---+
      #|| u | v | w | x |
      #|+---+---+---+---+
      #|| y | z |   |   |
      #|+---+---+---+---+
      #||   |   |   |   |
      #|+---+---+---+---+
      #||   |   |   |   |
      #|+---+---+---+---+
    ),
  )
}

///|
test "split_row_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  table.split(@tabular.Split::column(4)) |> ignore
  table.split(@tabular.Split::row(1).concat()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_row_2_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  table.split(@tabular.Split::column(4)) |> ignore
  table.split(@tabular.Split::row(2).concat()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | i | j | k | l | q | r | s | t | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| e | f | g | h | m | n | o | p | u | v | w | x |   |   |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_column_index_beyond_size_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(10000)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_row_index_beyond_size_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::row(10000)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_empty_table_test" {
  let table = @tabular.Table::from_rows([])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(10000)) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "split_column_zero_argument_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(0)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_row_zero_argument_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::row(0)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_blank_table_test" {
  let row : Array[String] = Array::make(26, "")
  let table = @tabular.Table::from_rows([row])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+--+--+--+--+--+--+--+--+--+--+--+--+
      #||  |  |  |  |  |  |  |  |  |  |  |  |
      #|+--+--+--+--+--+--+--+--+--+--+--+--+
    ),
  )
}

///|
test "split_blank_table_2_test" {
  let row : Array[String] = Array::make(26, "")
  let table = @tabular.Table::from_rows([row])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12).retain()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+--+--+--+--+--+--+--+--+--+--+--+--+
      #||  |  |  |  |  |  |  |  |  |  |  |  |
      #|+--+--+--+--+--+--+--+--+--+--+--+--+
      #||  |  |  |  |  |  |  |  |  |  |  |  |
      #|+--+--+--+--+--+--+--+--+--+--+--+--+
      #||  |  |  |  |  |  |  |  |  |  |  |  |
      #|+--+--+--+--+--+--+--+--+--+--+--+--+
    ),
  )
}

///|
test "split_zip_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(6)) |> ignore
  table.split(@tabular.Split::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | m | y | b | n | z | c | o | d | p | e | q | f | r |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| g | s |   | h | t |   | i | u | j | v | k | w | l | x |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_concat_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(6)) |> ignore
  table.split(@tabular.Split::row(2).concat()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | b | c | d | e | f | m | n | o | p | q | r | y | z |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| g | h | i | j | k | l | s | t | u | v | w | x |   |   |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_clean_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  table.split(@tabular.Split::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| a | y | b | z | c | d | e | f | g | h | i | j | k | l |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
      #|| m |   | n |   | o | p | q | r | s | t | u | v | w | x |
      #|+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    ),
  )
}

///|
test "split_retain_test" {
  let table = alpha_table()
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(12)) |> ignore
  table.split(@tabular.Split::row(2).retain()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+
      #|| a | y | b | z | c |  | d |  | e |  | f |  | g |  | h |  | i |  | j |  | k |  | l |  |
      #|+---+---+---+---+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+
      #|| m |   | n |   | o |  | p |  | q |  | r |  | s |  | t |  | u |  | v |  | w |  | x |  |
      #|+---+---+---+---+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+---+--+
    ),
  )
}

///|
test "split_mostly_blank_test" {
  let row : Array[String] = Array::make(33, "")
  row.push("A")
  let table = @tabular.Table::from_rows([row])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(5)) |> ignore
  table.split(@tabular.Split::row(2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+--+--+--+---+--+
      #||  |  |  |   |  |
      #|+--+--+--+---+--+
      #||  |  |  | A |  |
      #|+--+--+--+---+--+
    ),
  )
}

///|
test "split_scattered_values_test" {
  let row : Array[String] = Array::make(5, "")
  row.push("g")
  Array::make(27, "").each(fn(s) { row.push(s) })
  row.push("A")
  let table = @tabular.Table::from_rows([row])
  table.apply(@tabular.Style::ascii()) |> ignore
  table.split(@tabular.Split::column(5)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+--+--+---+--+
      #||   |  |  |   |  |
      #|+---+--+--+---+--+
      #|| g |  |  |   |  |
      #|+---+--+--+---+--+
      #||   |  |  | A |  |
      #|+---+--+--+---+--+
    ),
  )
}

///|
test "extract middle section" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
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
  table.extract_segment(@tabular.Rows::new(1, 3), @tabular.Columns::new(1, 4))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---------+---------+---------+
      #||   [0-0] |   [0-1] |   [0-2] |
      #|+---------+---------+---------+
      #||   [1-0] |   [1-1] |   [1-2] |
      #|+---------+---------+---------+
    ),
  )
}

///|
test "extract rows full" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.extract_rows(@tabular.Rows::all()) |> ignore
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
      #|| 2 |   2-0    |   2-1    |
      #|+---+----------+----------+
    ),
  )
}

///|
test "extract rows empty" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0"],
    ["0", "0-0"],
    ["1", "1-0"],
  ])
  table.extract_rows(@tabular.Rows::new(0, 0)) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "extract rows partial" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.extract_rows(@tabular.Rows::new(0, 3)) |> ignore
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
test "extract columns full" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.extract_columns(@tabular.Columns::all()) |> ignore
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
test "extract columns empty" {
  let table = @tabular.Table::from_rows([["N", "column 0"], ["0", "0-0"]])
  table.extract_columns(@tabular.Columns::new(0, 0)) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "extract columns partial" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
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
  table.extract_columns(@tabular.Columns::new(0, 2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-------+--------------+
      #||   [N] |   [column 0] |
      #|+-------+--------------+
      #||   [0] |   [0-0]      |
      #|+-------+--------------+
      #||   [1] |   [1-0]      |
      #|+-------+--------------+
      #||   [2] |   [2-0]      |
      #|+-------+--------------+
    ),
  )
}

///|
test "extract left after remove header" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_rows(@tabular.Rows::first()) |> ignore
  table.extract_segment(@tabular.Rows::all(), @tabular.Columns::new(0, 1))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+
      #|| 0 |
      #|+---+
      #|| 1 |
      #|+---+
      #|| 2 |
      #|+---+
    ),
  )
}

///|
test "extract right after remove header" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_rows(@tabular.Rows::first()) |> ignore
  table.extract_segment(@tabular.Rows::all(), @tabular.Columns::new(2, 4))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-----+
      #|| 0-1 | 0-2 |
      #|+-----+-----+
      #|| 1-1 | 1-2 |
      #|+-----+-----+
      #|| 2-1 | 2-2 |
      #|+-----+-----+
    ),
  )
}

///|
test "extract top after remove header" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_rows(@tabular.Rows::first()) |> ignore
  table.extract_segment(@tabular.Rows::new(0, 1), @tabular.Columns::all())
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+-----+-----+
      #|| 0 | 0-0 | 0-1 | 0-2 |
      #|+---+-----+-----+-----+
    ),
  )
}

///|
test "extract bottom after remove header" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_rows(@tabular.Rows::first()) |> ignore
  table.extract_segment(@tabular.Rows::new(2, 3), @tabular.Columns::all())
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+---+-----+-----+-----+
      #|| 2 | 2-0 | 2-1 | 2-2 |
      #|+---+-----+-----+-----+
    ),
  )
}

///|
test "extract beyond size yields empty" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_rows(@tabular.Rows::first()) |> ignore
  table.extract_segment(@tabular.Rows::new(3, 6), @tabular.Columns::new(3, 6))
  |> ignore
  inspect(table.to_string(), content="")
}

///|
test "extract empty table" {
  let table = @tabular.Table::from_rows([])
  table.extract_segment(@tabular.Rows::all(), @tabular.Columns::all()) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "remove all rows via rows" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
  ])
  table.apply(@tabular.Style::psql()) |> ignore
  table.remove_rows(@tabular.Rows::all()) |> ignore
  inspect(table.to_string(), content="")
}

///|
test "remove header then restyle with modern" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::align(@tabular.Align::left()),
  )
  |> ignore
  table.remove_rows(@tabular.Rows::new(0, 1)) |> ignore
  table.apply(@tabular.Style::modern()) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|┌───┬─────┬─────┐
      #|│ 0 │ 0-0 │ 0-1 │
      #|├───┼─────┼─────┤
      #|│ 1 │ 1-0 │ 1-1 │
      #|├───┼─────┼─────┤
      #|│ 2 │ 2-0 │ 2-1 │
      #|└───┴─────┴─────┘
    ),
  )
}

///|
test "extract with format preserves scoped formatting" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1"],
    ["0", "0-0", "0-1"],
    ["1", "1-0", "1-1"],
    ["2", "2-0", "2-1"],
  ])
  table.modify_segment(
    @tabular.Segment::all(),
    @tabular.Setting::format(@tabular.Format::surround("<", ">")),
  )
  |> ignore
  table.extract_segment(@tabular.Rows::new(1, 3), @tabular.Columns::new(0, 2))
  |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+-----+-------+
      #|| <0> | <0-0> |
      #|+-----+-------+
      #|| <1> | <1-0> |
      #|+-----+-------+
    ),
  )
}

///|
test "remove columns then extract rows" {
  let table = @tabular.Table::from_rows([
    ["N", "column 0", "column 1", "column 2"],
    ["0", "0-0", "0-1", "0-2"],
    ["1", "1-0", "1-1", "1-2"],
    ["2", "2-0", "2-1", "2-2"],
  ])
  table.remove_columns(@tabular.Columns::new(0, 1)) |> ignore
  table.extract_rows(@tabular.Rows::new(0, 2)) |> ignore
  inspect(
    table.to_string(),
    content=(
      #|+----------+----------+----------+
      #|| column 0 | column 1 | column 2 |
      #|+----------+----------+----------+
      #||   0-0    |   0-1    |   0-2    |
      #|+----------+----------+----------+
    ),
  )
}

///|
test "builder push_record basic" {
  let b = @tabular.Builder::default()
  b.push_record(["1", "2", "3"])
  b.push_record(["a", "b", "c"])
  b.push_record(["d", "e", "f"])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 1 | 2 | 3 |
      #|+---+---+---+
      #|| a | b | c |
      #|+---+---+---+
      #|| d | e | f |
      #|+---+---+---+
    ),
  )
}

///|
test "builder remove_record header" {
  let b = @tabular.Builder::default()
  b.push_record(["1", "2", "3"])
  b.push_record(["a", "b", "c"])
  b.push_record(["d", "e", "f"])
  b.remove_record(0)
  let table = b.build()
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
test "builder remove_record middle with different col count" {
  let b = @tabular.Builder::default()
  b.push_record(["a", "b", "c"])
  b.push_record(["1", "2", "3", "4", "5"])
  b.push_record(["d", "e", "f"])
  b.remove_record(1)
  let table = b.build()
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
test "builder push_column basic" {
  let b = @tabular.Builder::default()
  b.push_record(["1", "2", "3"])
  b.push_record(["a", "b", "c"])
  b.push_record(["d", "e", "f"])
  b.push_column(["4", "g", "h"])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+
      #|| 1 | 2 | 3 | 4 |
      #|+---+---+---+---+
      #|| a | b | c | g |
      #|+---+---+---+---+
      #|| d | e | f | h |
      #|+---+---+---+---+
    ),
  )
}

///|
test "builder push_column only" {
  let b = @tabular.Builder::default()
  b.push_column(["a", "d"])
  b.push_column(["b", "e"])
  b.push_column(["c", "f"])
  b.push_column(["g", "h"])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+
      #|| a | b | c | g |
      #|+---+---+---+---+
      #|| d | e | f | h |
      #|+---+---+---+---+
    ),
  )
}

///|
test "builder push_column with different lengths" {
  let b = @tabular.Builder::default()
  b.push_column(["4", "g", "h"])
  b.push_column(["5", "g", "h", "j"])
  b.push_column(["6"])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 4 | 5 | 6 |
      #|+---+---+---+
      #|| g | g |   |
      #|+---+---+---+
      #|| h | h |   |
      #|+---+---+---+
      #||   | j |   |
      #|+---+---+---+
    ),
  )
}

///|
test "builder insert_column" {
  let b = @tabular.Builder::default()
  b.push_record(["a", "b", "c"])
  b.push_record(["d", "e", "f"])
  b.insert_column(2, ["k", "n"])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+---+
      #|| a | b | k | c |
      #|+---+---+---+---+
      #|| d | e | n | f |
      #|+---+---+---+---+
    ),
  )
}

///|
test "builder different column counts" {
  let b = @tabular.Builder::default()
  b.push_record(["1", "2"])
  b.push_record(["a", "b", "c"])
  b.push_record(["d"])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 1 | 2 |   |
      #|+---+---+---+
      #|| a | b | c |
      #|+---+---+---+
      #|| d |   |   |
      #|+---+---+---+
    ),
  )
}

///|
test "builder set_empty fills missing cells" {
  let b = @tabular.Builder::default()
  b.push_record(["1", "2"])
  b.set_empty("NaN")
  b.push_record(["a", "b", "c"])
  b.push_record(["d"])
  let table = b.build()
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
test "builder clear" {
  let b = @tabular.Builder::default()
  b.push_record(["1", "2", "3"])
  b.push_record(["a", "b", "c"])
  b.clear()
  let table = b.build()
  inspect(table.to_string(), content="")
}

///|
test "builder from_rows with empty rows" {
  let b = @tabular.Builder::from_rows([["1", "2", "3"], [], [], ["d", "e", "f"]])
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 1 | 2 | 3 |
      #|+---+---+---+
      #||   |   |   |
      #|+---+---+---+
      #||   |   |   |
      #|+---+---+---+
      #|| d | e | f |
      #|+---+---+---+
    ),
  )
}

///|
test "builder clean removes empty columns" {
  let b = @tabular.Builder::from_rows([
    ["", "2", "3"],
    ["", "b", "c"],
    ["", "e", "f"],
  ])
  b.clean()
  let table = b.build()
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
test "builder clean removes empty middle column" {
  let b = @tabular.Builder::from_rows([
    ["1", "", "3"],
    ["a", "", "c"],
    ["d", "", "f"],
  ])
  b.clean()
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| 1 | 3 |
      #|+---+---+
      #|| a | c |
      #|+---+---+
      #|| d | f |
      #|+---+---+
    ),
  )
}

///|
test "builder clean removes empty rows" {
  let b = @tabular.Builder::from_rows([
    ["", "", ""],
    ["a", "b", "c"],
    ["d", "e", "f"],
  ])
  b.clean()
  let table = b.build()
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
test "builder clean removes empty middle row" {
  let b = @tabular.Builder::from_rows([
    ["1", "2", "3"],
    ["", "", ""],
    ["d", "e", "f"],
  ])
  b.clean()
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+---+
      #|| 1 | 2 | 3 |
      #|+---+---+---+
      #|| d | e | f |
      #|+---+---+---+
    ),
  )
}

///|
test "builder clean removes both empty rows and columns" {
  let b = @tabular.Builder::from_rows([
    ["1", "", "3"],
    ["", "", ""],
    ["d", "", "f"],
  ])
  b.clean()
  let table = b.build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+
      #|| 1 | 3 |
      #|+---+---+
      #|| d | f |
      #|+---+---+
    ),
  )
}

///|
test "builder clean all empty yields empty" {
  let b = @tabular.Builder::from_rows([["", "", ""], ["", "", ""], ["", "", ""]])
  b.clean()
  let table = b.build()
  inspect(table.to_string(), content="")
}

///|
test "builder index default" {
  let b = @tabular.Builder::from_rows([
    ["n", "name"],
    ["0", "Dmitriy"],
    ["1", "Vladislav"],
  ])
  let table = b.index().build()
  inspect(
    table.to_string(),
    content=(
      #|+---+---+-----------+
      #||   | n |   name    |
      #|+---+---+-----------+
      #|| 0 | 0 |  Dmitriy  |
      #|+---+---+-----------+
      #|| 1 | 1 | Vladislav |
      #|+---+---+-----------+
    ),
  )
}

///|
test "builder index hide" {
  let b = @tabular.Builder::from_rows([
    ["n", "name"],
    ["0", "Dmitriy"],
    ["1", "Vladislav"],
  ])
  let table = b.index().hide().build()
  inspect(
    table.to_string(),
    content=(
      #|+---+-----------+
      #|| n |   name    |
      #|+---+-----------+
      #|| 0 |  Dmitriy  |
      #|+---+-----------+
      #|| 1 | Vladislav |
      #|+---+-----------+
    ),
  )
}

///|
test "builder index set column" {
  let b = @tabular.Builder::from_rows([
    ["n", "name"],
    ["0", "Dmitriy"],
    ["1", "Vladislav"],
  ])
  let table = b.index().column(1).build()
  inspect(
    table.to_string(),
    content=(
      #|+-----------+---+
      #||           | n |
      #|+-----------+---+
      #||   name    |   |
      #|+-----------+---+
      #||  Dmitriy  | 0 |
      #|+-----------+---+
      #|| Vladislav | 1 |
      #|+-----------+---+
    ),
  )
}

///|
test "builder index column with custom name" {
  let b = @tabular.Builder::from_rows([
    ["n", "name"],
    ["0", "Dmitriy"],
    ["1", "Vladislav"],
  ])
  let table = b.index().column(1).name(Some("Hello")).build()
  inspect(
    table.to_string(),
    content=(
      #|+-----------+---+
      #||           | n |
      #|+-----------+---+
      #||   Hello   |   |
      #|+-----------+---+
      #||  Dmitriy  | 0 |
      #|+-----------+---+
      #|| Vladislav | 1 |
      #|+-----------+---+
    ),
  )
}

///|
test "builder index column name none" {
  let b = @tabular.Builder::from_rows([
    ["n", "name"],
    ["0", "Dmitriy"],
    ["1", "Vladislav"],
  ])
  let table = b.index().column(1).name(None).build()
  inspect(
    table.to_string(),
    content=(
      #|+-----------+---+
      #||           | n |
      #|+-----------+---+
      #||  Dmitriy  | 0 |
      #|+-----------+---+
      #|| Vladislav | 1 |
      #|+-----------+---+
    ),
  )
}

///|
test "builder index transpose" {
  let b = @tabular.Builder::from_rows([
    ["n", "name", "zz"],
    ["0", "Dmitriy", "123"],
    ["1", "Vladislav", "123"],
  ])
  let table = b.index().transpose().build()
  inspect(
    table.to_string(),
    content=(
      #|+------+---------+-----------+
      #||      |    0    |     1     |
      #|+------+---------+-----------+
      #||  n   |    0    |     1     |
      #|+------+---------+-----------+
      #|| name | Dmitriy | Vladislav |
      #|+------+---------+-----------+
      #||  zz  |   123   |    123    |
      #|+------+---------+-----------+
    ),
  )
}

///|
test "builder count_records and count_columns" {
  let b = @tabular.Builder::default()
  b.push_record(["a", "b", "c"])
  b.push_record(["d", "e"])
  inspect(b.count_records(), content="2")
  inspect(b.count_columns(), content="3")
}
