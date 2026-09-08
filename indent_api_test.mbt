///|
test "indent sides support constructors conversion map and ordered fold" {
  let sides = @tabular.Sides::new(1, 2, 3, 4)
  assert_eq(sides.fold("", (out, value) => out + value.to_string()), "1234")
  let pads = sides.map(value => @tabular.Indent::new(value, '#'))
  assert_eq(@tabular.Padding::from_sides(pads).to_sides(), pads)
  assert_eq(@tabular.Margin::from_sides(pads).to_sides(), pads)
  assert_true(@tabular.Indent::default().is_empty())
  let empty : @tabular.Sides[@tabular.Indent] = @tabular.Sides::default()
  assert_eq(empty, @tabular.Sides::filled(@tabular.Indent::zero()))
  let unset : @tabular.Sides[Int?] = @tabular.Sides::filled(None)
  assert_true(unset.is_empty())
  assert_false(@tabular.Sides::new(None, Some(0), None, None).is_empty())
}

///|
test "indent colors accept color buffers and static ANSI pairs" {
  let ansi = @papergrid.ANSIBuf::new("<", ">")
  let colors = @tabular.Sides::filled(ansi)
  let padding = @tabular.PaddingColor::from_sides(colors)
  assert_eq(padding.to_sides(), colors)
  let table = @tabular.Table::from_rows([["x"]])
    .with_(@tabular.Padding::new(1, 1, 0, 0))
    .with_(padding)
  assert_eq(table.to_string(), "+---+\n|< >x< >|\n+---+")
  assert_eq(
    table.config.get_padding_color(0, 0),
    colors.map(color => Some(color)),
  )
  table.with_(@tabular.PaddingColor::filled(ansi.as_ref())) |> ignore
  assert_eq(
    table.config.get_padding_color(0, 0),
    colors.map(color => Some(color)),
  )
  table.with_(@tabular.MarginColor::new(ansi, ansi, ansi, ansi)) |> ignore
  assert_eq(table.config.get_margin_color(), colors.map(color => Some(color)))
  table.with_(@tabular.MarginColor::empty()) |> ignore
  assert_eq(
    table.config.get_margin_color(),
    @tabular.Sides::filled(Some(@papergrid.ANSIBuf::empty())),
  )
}

///|
test "typed margin offsets retain start and end zero identity" {
  let config = @papergrid.SpannedConfig::default()
  assert_eq(
    config.get_margin_offset(),
    @tabular.Sides::filled(@tabular.Offset::Start(0)),
  )
  let offsets = @tabular.Sides::new(
    @tabular.Offset::Start(0),
    @tabular.Offset::End(0),
    @tabular.Offset::Start(2),
    @tabular.Offset::End(3),
  )
  config.set_margin_offsets(offsets)
  assert_eq(config.get_margin_offset(), offsets)
  assert_eq(@tabular.Offset::from_int(0), @tabular.Offset::End(0))
  assert_eq(@tabular.Offset::from_int(-2), @tabular.Offset::End(2))
  assert_eq(@tabular.Offset::from_int(2), @tabular.Offset::Start(2))
  let sides = @tabular.Sides::filled(@tabular.Indent::new(2, '#'))
  config.set_margin_sides(sides)
  assert_eq(config.get_margin(), sides)
}

///|
test "padding fills and colors follow coordinate remapping" {
  let table = @tabular.Table::from_rows([["a"], ["b"], ["c"]])
  let pad = @tabular.Padding::new(1, 2, 1, 2).fill('>', '<', '^', 'v')
  table
  .modify((2, 0), pad)
  .modify((2, 0), @tabular.PaddingColor::filled(@tabular.Color::bg_red()))
  |> ignore
  table.remove_rows(@tabular.Rows::one(0)) |> ignore
  assert_eq(table.config.get_padding(1, 0), pad.to_sides())
  assert_eq(
    table.config.get_padding_color(1, 0),
    @tabular.Sides::filled(Some(@tabular.Color::bg_red().to_ansi_buf())),
  )
  table.set_padding(@tabular.Padding::new(1, 1, 0, 0)) |> ignore
  assert_eq(
    table.config.get_padding(1, 0),
    @tabular.Padding::new(1, 1, 0, 0).to_sides(),
  )
}
