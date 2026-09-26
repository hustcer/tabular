///|
test "table height limits include legacy render-time wrapping" {
  let table = @tabular.Table::from_rows([["abcdefghij"]]).set_width(
    @tabular.Width::wrap(1),
  )
  assert_eq(table.total_height(), 12)
  table.with_(@tabular.Height::limit(5)) |> ignore
  assert_eq(table.total_height(), 5)
  assert_eq(table.to_string(), "+---+\n| a |\n| b |\n| c |\n+---+")
}

///|
test "table height increase never shrinks legacy rendered height" {
  let table = @tabular.Table::from_rows([["x"]]).set_height(
    @tabular.Height::increase(10),
  )
  let original = table.to_string()
  table.with_(@tabular.Height::increase(5)) |> ignore
  assert_eq(table.total_height(), 12)
  assert_eq(table.to_string(), original)
  table.with_(@tabular.Height::increase(15)) |> ignore
  assert_eq(table.total_height(), 15)
  assert_eq(@papergrid.count_lines(table.to_string()), 15)
}

///|
test "table height options include scoped modes and margins" {
  let table = @tabular.Table::from_rows([["abcdef"], ["x"]])
    .modify_cell(
      @tabular.Cell::new(0, 0),
      @tabular.Setting::width(@tabular.Width::wrap(1)),
    )
    .modify_cell(
      @tabular.Cell::new(1, 0),
      @tabular.Setting::height(@tabular.Height::increase(3)),
    )
    .with_(@tabular.Margin::new(left=0, right=0, top=1, bottom=1))
  assert_eq(table.total_height(), 14)
  table.with_(@tabular.Height::limit(10)) |> ignore
  assert_eq(table.total_height(), 10)
  assert_eq(@papergrid.count_lines(table.to_string()), 10)
}

///|
test "table height growth can expand legacy zero-height rows" {
  let priorities : Array[&@tabular.ResizeSelector] = [
    @tabular.Priority::round_robin(),
    @tabular.Priority::first(),
    @tabular.Priority::last(),
    @tabular.PriorityMin::default(),
    @tabular.PriorityMax::default(),
  ]
  for priority in priorities {
    let table = @tabular.Table::from_rows([["x"]])
      .set_height(@tabular.Height::limit(0))
      .with_(@tabular.Height::increase(5).priority(priority))
    assert_eq(table.total_height(), 5)
    assert_eq(table.to_string(), "++\n||\n||\n||\n++")
  }
  let table = @tabular.Table::from_rows([["x"], ["y"]])
    .set_height(@tabular.Height::limit(0))
    .with_(@tabular.Height::increase(8))
  assert_eq(table.dimension_snapshot().get_heights(), Some([3, 2]))
  assert_eq(@papergrid.count_lines(table.to_string()), 8)
}
