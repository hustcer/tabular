///|
fn[T : @tabular.TableOption] assert_reusable_resize(
  option : T,
  rows : Array[Array[String]],
) -> Unit raise {
  let first = @tabular.Table::from_rows(rows.map(Array::copy)).with_(option)
  let second = @tabular.Table::from_rows(rows.map(Array::copy)).with_(option)
  assert_eq(first.to_string(), second.to_string())
  assert_eq(first.rows, second.rows)
  assert_eq(first.dimension_snapshot(), second.dimension_snapshot())
}

///|
test "width options start independent priority sequences when reused" {
  assert_reusable_resize(@tabular.Width::increase(10), [["a", "b"]])
  assert_reusable_resize(@tabular.Width::wrap(10), [["abcd", "efgh"]])
  assert_reusable_resize(@tabular.Width::truncate(10), [["abcd", "efgh"]])
  let priority = @tabular.Priority::round_robin()
  assert_eq(priority.select([], [3, 3]), Some(0))
  let option = @tabular.Width::increase(10).priority(priority)
  let table = @tabular.Table::from_rows([["a", "b"]]).with_(option)
  assert_eq(table.dimension_snapshot().get_widths(), Some([4, 3]))
  // Applying the option leaves the caller's direct selection sequence intact.
  assert_eq(priority.select([], [3, 3]), Some(1))
}

///|
test "height options start independent priority sequences when reused" {
  assert_reusable_resize(
    @tabular.Height::increase(6).priority(@tabular.Priority::round_robin()),
    [["a"], ["b"]],
  )
  assert_reusable_resize(
    @tabular.Height::limit(6).priority(@tabular.Priority::round_robin()),
    [["a\nb"], ["c\nd"]],
  )
}

///|
test "composed resize settings can be reused" {
  let settings = @tabular.Settings::default()
    .with_(@tabular.Width::increase(10))
    .with_(
      @tabular.Height::increase(6).priority(@tabular.Priority::round_robin()),
    )
  assert_reusable_resize(settings, [["a", "b"], ["c", "d"]])
  let option = @tabular.Width::increase(10)
  assert_reusable_resize([option], [["a", "b"]])
  assert_reusable_resize((@tabular.Style::ascii(), option), [["a", "b"]])
}

///|
test "last priority always follows the current shape" {
  let priority = @tabular.Priority::last()
  assert_eq(priority.select([], [2]), Some(0))
  assert_eq(priority.select([], [2, 2]), Some(1))
  assert_eq(priority.select([], []), None)
  assert_eq(priority.select([0, 2, 0], [1, 2, 0]), Some(0))
  let option = @tabular.Width::increase(10).priority(priority)
  @tabular.Table::from_rows([["a"]]).with_(option) |> ignore
  let table = @tabular.Table::from_rows([["a", "b"]]).with_(option)
  assert_eq(table.dimension_snapshot().get_widths(), Some([3, 4]))
}

///|
struct StatelessResizeSelector {}

///|
impl @tabular.ResizeSelector for StatelessResizeSelector with fn select(
  _self,
  minimums,
  sizes,
) {
  for index, size in sizes {
    if size > minimums.get(index).unwrap_or(0) {
      return Some(index)
    }
  }
  None
}

///|
test "custom stateless selectors retain the default fresh implementation" {
  assert_reusable_resize(
    @tabular.Width::increase(10).priority(StatelessResizeSelector::{ }),
    [["a", "b"]],
  )
}

///|
struct ConfiguredResizeSelector {
  start : Int
  mut cursor : Int
}

///|
impl @tabular.ResizeSelector for ConfiguredResizeSelector with fn fresh(self) {
  ConfiguredResizeSelector::{ start: self.start, cursor: self.start, }
}

///|
impl @tabular.ResizeSelector for ConfiguredResizeSelector with fn select(
  self,
  _minimums,
  sizes,
) {
  guard !sizes.is_empty() else { return None }
  let selected = self.cursor % sizes.length()
  self.cursor = selected + 1
  Some(selected)
}

///|
test "custom stateful selectors retain settings in independent resize state" {
  let priority = ConfiguredResizeSelector::{ start: 1, cursor: 0, }
  let option = @tabular.Width::increase(10).priority(priority)
  assert_reusable_resize(option, [["a", "b"]])
  let table = @tabular.Table::from_rows([["a", "b"]]).with_(option)
  assert_eq(table.dimension_snapshot().get_widths(), Some([3, 4]))
  assert_eq(priority.cursor, 0)
}

///|
test "resize selectors remain usable through trait objects" {
  let priority : &@tabular.ResizeSelector = @tabular.Priority::round_robin()
  assert_eq(priority.select([], [2, 2]), Some(0))
  let fresh = priority.fresh()
  assert_eq(fresh.select([], [2, 2]), Some(0))
  assert_eq(priority.select([], [2, 2]), Some(1))
  assert_reusable_resize(@tabular.Width::increase(10).priority(priority), [
    ["a", "b"],
  ])
}

///|
test "negative lower bounds allow zero sizes without changing default selection" {
  let priorities : Array[&@tabular.ResizeSelector] = [
    @tabular.Priority::round_robin(),
    @tabular.Priority::first(),
    @tabular.Priority::last(),
    @tabular.PriorityMin::default(),
    @tabular.PriorityMax::default(),
  ]
  for priority in priorities {
    assert_eq(priority.select([], [0, 0]), None)
    assert_eq(priority.select([0, 0], [0, 0]), None)
    assert_true(priority.select([-1, -1], [0, 0]) is Some(_))
    assert_eq(priority.select([], [0, 0]), None)
  }
  assert_eq(@tabular.PriorityMin::default().select([-1, -1], [1, 0]), Some(1))
  assert_eq(@tabular.PriorityMax::default().select([-1, -1], [1, 0]), Some(0))
}
