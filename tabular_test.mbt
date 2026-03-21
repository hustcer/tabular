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
