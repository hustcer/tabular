///|
test "height constructors preserve text and table option distinctions" {
  let table = @tabular.Table::from_rows([["a"], ["b\nc"]])
  table.modify((0, 0), @tabular.CellHeightIncrease::new(3)) |> ignore
  assert_eq(table.rows, [["a\n\n"], ["b\nc"]])
  table.modify((1, 0), @tabular.CellHeightLimit::new(1)) |> ignore
  assert_eq(table.rows, [["a\n\n"], ["b"]])
  table.with_(
    @tabular.TableHeightIncrease::new(12).priority(
      @tabular.PriorityMax::prefer_first(),
    ),
  )
  |> ignore
  assert_eq(table.total_height(), 12)
  assert_eq(table.rows, [["a\n\n"], ["b"]])
  table.with_(
    @tabular.TableHeightLimit::new(4).priority(
      @tabular.PriorityMax::prefer_first(),
    ),
  )
  |> ignore
  assert_eq(table.total_height(), 4)
  assert_eq(table.rows, [[""], ["b"]])
}

///|
test "height list constructors copy inputs and preserve excess cache values" {
  let heights = [3, 2, 99]
  let option = @tabular.HeightList::new(heights)
  heights[0] = 20
  let table = @tabular.Table::from_rows([["a"], ["b"]]).with_(option)
  assert_eq(table.dimension_snapshot().get_heights(), Some([3, 2, 99]))
  assert_eq(table.total_height(), 8)
  let expected = table.to_string()
  table.with_(@tabular.HeightList::from_array([3, 2])) |> ignore
  assert_eq(table.to_string(), expected)
  table.with_(@tabular.HeightList::from_iter([3, 2].iter())) |> ignore
  assert_eq(table.to_string(), expected)
}

///|
test "legacy height setters preserve render-time behavior" {
  let legacy = @tabular.Table::from_rows([["a\nb\nc"]])
  legacy.set_height(@tabular.Height::limit(2)) |> ignore
  assert_eq(legacy.rows, [["a\nb\nc"]])
  assert_eq(legacy.to_string(), "+---+\n| a |\n| b |\n+---+")
  let text = @tabular.Table::from_rows([["a\nb\nc"]])
  text.modify((0, 0), @tabular.Height::limit(2)) |> ignore
  assert_eq(text.rows, [["a\nb"]])
  assert_eq(text.to_string(), legacy.to_string())
}

///|
test "height options handle empty and invalid entities without records" {
  for rows in [[], [[]]] {
    let table = @tabular.Table::from_rows(rows)
    table.with_(@tabular.Height::increase(20)).with_(@tabular.Height::limit(0))
    |> ignore
    assert_true(table.dimension_snapshot().is_empty())
    table.modify((20, 20), @tabular.Height::increase(5)) |> ignore
    table.modify((0, 0), @tabular.Height::limit(-1)) |> ignore
    assert_eq(table.rows, rows)
    assert_eq(table.to_string(), "")
  }
}

///|
test "cell height mutations invalidate both cached axes" {
  let table = @tabular.Table::from_rows([["long value\nx"]])
    .with_(@tabular.Width::list([20]))
    .with_(@tabular.Height::list([8]))
  table.modify((0, 0), @tabular.Height::limit(1)) |> ignore
  assert_true(table.dimension_snapshot().is_empty())
  assert_eq(table.rows, [["long value"]])
}
