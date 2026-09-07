///|
// Upstream: tabled/src/settings/color/mod.rs::tests::test_xor_operation
test "upstream color test_xor_operation" {
  assert_eq(
    @tabular.Color::fg_black().bitor(@tabular.Color::fg_blue()),
    @tabular.Color::new("\u001b[30m\u001b[34m", "\u001b[39m"),
  )
  assert_eq(
    @tabular.Color::fg_bright_green().bitor(@tabular.Color::bg_blue()),
    @tabular.Color::new("\u001b[92m\u001b[44m", "\u001b[39m\u001b[49m"),
  )
  assert_eq(
    @tabular.Color::new("...", "!!!").bitor(@tabular.Color::new("@@@", "###")),
    @tabular.Color::new("...@@@", "!!!###"),
  )
  assert_eq(
    @tabular.Color::new("...", "!!!")
    .bitor(@tabular.Color::new("@@@", "###"))
    .bitor(@tabular.Color::new("$$$", "%%%")),
    @tabular.Color::new("...@@@$$$", "!!!###%%%"),
  )
}

///|
test "colorize matches Rust logical line and newline behavior" {
  let color = @tabular.Color::new("<", ">")
  assert_eq(color.colorize(""), "")
  assert_eq(color.colorize("\n"), "<>")
  assert_eq(color.colorize("a\n\n"), "<a>\n<>")
  assert_eq(color.colorize("a\r\nb\r"), "<a>\n<b\r>")
  assert_eq(color.colorize("a\r\r\n"), "<a\r>")
}

///|
test "color constructors preserve ANSI components and static identity" {
  let fg = @tabular.Color::rgb_fg(0, 128, 255)
  assert_eq(fg.get_prefix(), "\u001b[38;2;0;128;255m")
  assert_eq(fg.get_suffix(), "\u001b[39m")
  assert_true(fg.as_ansi_str() is None)
  assert_eq(
    @tabular.Color::rgb_bg(255, 128, 0).colorize("x"),
    "\u001b[48;2;255;128;0mx\u001b[49m",
  )
  assert_eq(@tabular.Color::from_ansi_buf(fg.to_ansi_buf()), fg)
  assert_true(@tabular.Color::empty().is_empty())
  assert_true(@tabular.Color::default().as_ansi_str() is Some(_))
  assert_true(@tabular.Color::fg_red().as_ansi_str() is Some(_))
  assert_eq(
    @tabular.Color::fg_red() | @tabular.Color::fg_red(),
    @tabular.Color::new("\u001b[31m", "\u001b[39m"),
  )
}
