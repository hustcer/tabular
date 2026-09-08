///|
fn upstream_width_state(mode : String) -> @tabular.Table {
  let table = @tabular.Table::from_rows([["abc", "xy"], ["de", "z"]])
  match mode {
    "list" => table.with_(@tabular.Width::list([8, 5])) |> ignore
    "long-list" => table.with_(@tabular.Width::list([8, 5, 99])) |> ignore
    "short-list" =>
      table.with_(@tabular.Width::list([8, 5])).with_(@tabular.Width::list([1]))
      |> ignore
    "align" =>
      table
      .with_(@tabular.Width::list([8, 5]))
      .with_(@tabular.Alignment::right())
      |> ignore
    "cell-align" =>
      table
      .with_(@tabular.Width::list([8, 5]))
      .modify((0, 0), @tabular.Alignment::right())
      |> ignore
    "settings" =>
      table.with_(
        @tabular.Settings::new(
          @tabular.Width::list([8, 5]),
          @tabular.Alignment::right(),
        ),
      )
      |> ignore
    "array" => table.with_([@tabular.Width::list([8, 5])]) |> ignore
    "nested" => {
      table.with_(@tabular.Width::list([5, 4])) |> ignore
      table.with_(
        (
          @tabular.Modify::new((0, 0)).with_("a very long string"),
          @tabular.Width::truncate(12),
        ),
      )
      |> ignore
    }
    "record-wrap" =>
      table.modify(@tabular.Segment::all(), @tabular.Width::wrap(2)) |> ignore
    "record-increase" =>
      table.modify(
        @tabular.Segment::all(),
        @tabular.Width::increase(5).fill_with('.'),
      )
      |> ignore
    "max" =>
      table.modify(
        @tabular.Segment::all(),
        @tabular.Width::increase(@tabular.Max::new()),
      )
      |> ignore
    "min" =>
      table.modify(
        @tabular.Segment::all(),
        @tabular.Width::truncate(@tabular.Min::new()),
      )
      |> ignore
    "percent" =>
      table.with_(@tabular.Width::wrap(@tabular.Percent::new(75))) |> ignore
    "percent-increase" =>
      table.with_(@tabular.Width::increase(@tabular.Percent::new(200)))
      |> ignore
    "minimum-priority" =>
      table.with_(
        @tabular.Width::increase(20).priority(
          @tabular.PriorityMin::prefer_first(),
        ),
      )
      |> ignore
    "maximum-priority" =>
      table.with_(
        @tabular.Width::increase(20).priority(
          @tabular.PriorityMax::prefer_first(),
        ),
      )
      |> ignore
    "justify-max" => table.with_(@tabular.UniformWidth::max()) |> ignore
    "justify-min" => table.with_(@tabular.UniformWidth::min()) |> ignore
    "mixed-padding" =>
      table
      .modify((0, 0), @tabular.Padding::new(1, 1, 2, 0))
      .modify((0, 1), @tabular.Padding::new(1, 1, 0, 3))
      .with_(@tabular.Width::increase(14))
      |> ignore
    "row-span" =>
      table
      .modify((0, 0), @tabular.Span::row(2))
      .modify((1, 0), "a very long hidden value")
      .with_(@tabular.Width::increase(14))
      |> ignore
    "crlf" =>
      table.modify((0, 0), "a\r\nb\r\n").with_(@tabular.Width::increase(12))
      |> ignore
    "heights" => table.dimension_cache().set_heights([3, 2])
    "height-row-hint" => {
      table.dimension_cache().set_heights([3, 2])
      table.with_(@tabular.Width::wrap(100)) |> ignore
    }
    "height-no-hint" => {
      table.dimension_cache().set_heights([3, 2])
      table.with_(@tabular.Width::truncate(100)) |> ignore
    }
    "color" =>
      table.with_(@tabular.Width::list([8, 5])).with_(@tabular.Color::fg_red())
      |> ignore
    _ => abort("Unknown width state case")
  }
  table
}
