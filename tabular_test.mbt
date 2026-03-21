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
