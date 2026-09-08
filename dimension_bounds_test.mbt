///|
test "column growth through input aliases remeasures a short width cache" {
  let rows = [["a"]]
  let table = @tabular.Table::from_rows(rows).with_(@tabular.Width::list([10]))
  rows[0].push("bb")
  let fresh = @tabular.Table::from_rows(rows)
  assert_eq(table.to_string(), fresh.to_string())
  assert_eq(table.total_width(), 10)
  assert_eq(table.dimension_snapshot().get_widths(), Some([10]))
}

///|
test "row growth remeasures a short height cache without mutating it on reads" {
  let table = @tabular.Table::from_rows([["a"]]).with_(
    @tabular.Height::list([4]),
  )
  table.rows.push(["b\nc"])
  let fresh = @tabular.Table::from_rows(table.rows)
  assert_eq(table.to_string(), fresh.to_string())
  assert_eq(table.total_height(), 6)
  assert_eq(table.dimension_snapshot().get_heights(), Some([4]))
}

///|
test "explicitly incomplete dimension arrays are estimated before use" {
  let table = @tabular.Table::from_rows([["abc", "d"], ["e", "f"]])
  let dims = table.dimension_cache()
  dims.set_widths([])
  dims.set_heights([5])
  let fresh = @tabular.Table::from_rows(table.rows)
  assert_eq(table.to_string(), fresh.to_string())
  assert_eq(table.total_width(), 11)
  assert_eq(table.total_height(), 5)
  assert_eq(dims.get_widths(), Some([]))
  assert_eq(dims.get_heights(), Some([5]))
  dims.estimate(table)
  assert_eq(dims.get_widths(), Some([5, 3]))
  assert_eq(dims.get_heights(), Some([1, 1]))
  dims.set_widths([3])
  table.with_(@tabular.Width::increase(15)) |> ignore
  assert_eq(table.total_width(), 15)
}
