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
      #|+--------+----+
      #||language|year|
      #|+--------+----+
      #||Rust    |2010|
      #|+--------+----+
      #||MoonBit |2022|
      #|+--------+----+
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
      #|╭─┬─┬─╮
      #|│0│1│2│
      #|├─┼─┼─┤
      #|│0│0│0│
      #|├─┼─┼─┤
      #|│1│2│3│
      #|├─┼─┼─┤
      #|│2│4│6│
      #|╰─┴─┴─╯
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
      #|┌─┬─┬─┬─┐
      #|│ │0│1│2│
      #|├─┼─┼─┼─┤
      #|│0│0│0│0│
      #|├─┼─┼─┼─┤
      #|│1│1│2│3│
      #|├─┼─┼─┼─┤
      #|│2│2│4│6│
      #|└─┴─┴─┴─┘
    ),
  )
}
