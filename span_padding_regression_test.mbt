///|
test "row-span boundaries preserve top padding" {
  let table = @tabular.Table::from_rows([["x"], [""]])
    .with_(
      @tabular.Padding::new(0, 0, 2, 0).fill(
        left=' ',
        right=' ',
        top='^',
        bottom=' ',
      ),
    )
    .modify((0, 0), @tabular.Span::row(2))
  // Reference: tabled 6f40434650aa0c8a27ecb243d42af605b4206b73.
  assert_eq(table.to_string(), "+-+\n|^|\n+^+\n|x|\n+-+")
  assert_eq(table.total_height(), 5)
}

///|
test "row-span boundaries preserve padding colors and empty lines" {
  for (top, bottom) in [(2, 0), (0, 2), (1, 1)] {
    for text in ["x", "x\n\ny"] {
      let table = @tabular.Table::from_rows([[text], [""]])
        .with_(
          @tabular.Padding::new(0, 0, top, bottom).fill(
            left=' ',
            right=' ',
            top='^',
            bottom='v',
          ),
        )
        .with_(@tabular.PaddingColor::filled(@tabular.Color::bg_red()))
        .modify((0, 0), @tabular.Span::row(2))
      assert_eq(@papergrid.count_lines(table.to_string()), table.total_height())
      let plain = @papergrid.strip_ansi(table.to_string())
      assert_eq(plain.iter().filter(ch => ch == '^').count(), top)
      assert_eq(plain.iter().filter(ch => ch == 'v').count(), bottom)
      if top == 2 && text == "x" {
        assert_true(table.to_string().contains("+\u001b[41m^\u001b[49m+"))
      }
    }
  }
}
