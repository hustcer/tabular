///|
test "legacy mutators invalidate cached dimensions after record and layout changes" {
  let table = @tabular.Table::from_rows([["abc", "xy"]])
  table.with_(@tabular.Width::list([8, 5])) |> ignore
  table.set_padding(@tabular.Padding::zero()) |> ignore
  assert_true(table.get_dimension().is_empty())
  assert_eq(table.total_width(), 8)
  table.with_(@tabular.Width::list([8, 5])).rotate(@tabular.Rotate::Left)
  |> ignore
  assert_true(table.get_dimension().is_empty())
  assert_eq(table.shape(), (2, 1))
  assert_eq(table.total_width(), 5)
  table
  .with_(@tabular.Width::list([8]))
  .modify_cell(
    @tabular.Cell::new(0, 0),
    @tabular.Setting::format(@tabular.Format::value("abcdefghij")),
  )
  |> ignore
  assert_true(table.get_dimension().is_empty())
  assert_eq(table.total_width(), 12)
}

///|
test "complete dimension axis invalidation and independent snapshots" {
  let table = @tabular.Table::from_rows([["abc", "xy"]])
  let dims = table.get_dimension_mut()
  dims.estimate(table)
  assert_true(dims.is_complete())
  assert_eq(dims.get_width(0), 5)
  assert_eq(dims.get_height(0), 1)
  let before = table.get_dimension()
  dims.reastimate(Some(@tabular.Entity::Column(0)))
  assert_eq(dims.get_widths(), None)
  assert_eq(dims.get_heights(), Some([1]))
  assert_eq(before.get_widths(), Some([5, 4]))
  dims.estimate(table)
  dims.reastimate(Some(@tabular.Entity::Row(0)))
  assert_eq(dims.get_widths(), Some([5, 4]))
  assert_eq(dims.get_heights(), None)
  dims.reastimate(Some(@tabular.Entity::Cell(0, 0)))
  assert_true(dims.is_empty())
  let values = [7, 6]
  dims.set_widths(values)
  values[0] = 0
  assert_eq(dims.get_width(0), 7)
  dims.get_widths().unwrap()[0] = 100
  assert_eq(dims.get_width(0), 7)
  dims.clear()
  assert_true(dims.is_empty())
}

///|
test "width constructors and legacy conversion preserve their respective semantics" {
  assert_eq(@tabular.Wrap::wrap("hello world", 7, true), "hello \nworld")
  assert_eq(@tabular.Truncate::truncate("hello", 2), "he")
  let a = @tabular.Table::from_rows([["abcd"]]).with_(
    @tabular.WidthList::from_iter([8].iter()),
  )
  let b = @tabular.Table::from_rows([["abcd"]]).with_(
    @tabular.WidthList::from_array([8]),
  )
  assert_eq(a.to_string(), b.to_string())
  a.set_width(@tabular.Width::wrap(2)) |> ignore
  assert_eq(a.rows, [["abcd"]])
  assert_eq(a.to_string(), "+----+\n| ab |\n| cd |\n+----+")
  b.modify((0, 0), @tabular.Width::wrap(2)) |> ignore
  assert_eq(b.rows, [["ab\ncd"]])
  assert_eq(a.to_string(), b.to_string())
}

///|
test "margin fills each side and invalidates old dimension cache" {
  let table = @tabular.Table::from_rows([["a"]])
    .with_(@tabular.Width::list([8]))
    .with_(@tabular.Margin::new(1, 1, 1, 1).fill('>', '<', 'v', '^'))
  assert_true(table.get_dimension().is_empty())
  assert_eq(table.to_string(), "vvvvvvv\n>+---+<\n>| a |<\n>+---+<\n^^^^^^^")
  table.with_(@tabular.Margin::new(2, 3, 0, 1)) |> ignore
  assert_eq(table.total_width(), 10)
  assert_eq(table.total_height(), 4)
}
