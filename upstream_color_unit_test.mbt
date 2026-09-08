///|
// Upstream: tabled/src/settings/color/mod.rs::tests::test_try_from
test "upstream color test_try_from" {
  assert_eq(@tabular.Color::try_from(""), Err(()))
  assert_eq(
    @tabular.Color::try_from("\u001b[31m\u001b[42m\u001b[39m\u001b[49m"),
    Err(()),
  )
  assert_eq(@tabular.Color::try_from("."), Ok(@tabular.Color::new("", "")))
  assert_eq(@tabular.Color::try_from("...."), Ok(@tabular.Color::new("", "")))
  for text in [".", "...", ".\n.\n.", ".\n.\n.\n", "\n"] {
    assert_eq(
      @tabular.Color::try_from(
        "\u001b[31m\u001b[42m" + text + "\u001b[39m\u001b[49m",
      ),
      Ok(@tabular.Color::new("\u001b[31m\u001b[42m", "\u001b[39m\u001b[49m")),
    )
  }
}

///|
// Upstream: tabled/src/settings/color/mod.rs::tests::test_rgb_color
test "upstream color test_rgb_color" {
  assert_eq(
    @tabular.Color::rgb_bg(255, 255, 255),
    @tabular.Color::new("\u001b[48;2;255;255;255m", "\u001b[49m"),
  )
  assert_eq(
    @tabular.Color::rgb_bg(0, 255, 128),
    @tabular.Color::new("\u001b[48;2;0;255;128m", "\u001b[49m"),
  )
  assert_eq(
    @tabular.Color::rgb_fg(0, 255, 128),
    @tabular.Color::new("\u001b[38;2;0;255;128m", "\u001b[39m"),
  )
  assert_eq(
    @tabular.Color::rgb_fg(255, 255, 255),
    @tabular.Color::new("\u001b[38;2;255;255;255m", "\u001b[39m"),
  )
  assert_eq(
    @tabular.Color::rgb_bg(255, 255, 255) | @tabular.Color::rgb_fg(0, 0, 0),
    @tabular.Color::new(
      "\u001b[48;2;255;255;255m\u001b[38;2;0;0;0m", "\u001b[49m\u001b[39m",
    ),
  )
}

///|
// Upstream: tabled/src/settings/color/mod.rs::tests::test_is_empty
test "upstream color test_is_empty" {
  assert_true(@tabular.Color::empty().is_empty())
  assert_false(@tabular.Color::fg_black().is_empty())
  assert_false(@tabular.Color::bg_red().is_empty())
  assert_false(@tabular.Color::new("a", "b").is_empty())
  assert_true(@tabular.Color::new("", "").is_empty())
}

///|
// Upstream: tabled/src/settings/color/mod.rs::tests::test_text_attribute_constants
test "upstream color test_text_attribute_constants" {
  let cases = [
    (@tabular.Color::blink(), "\u001b[5m", "\u001b[25m"),
    (@tabular.Color::bold(), "\u001b[1m", "\u001b[22m"),
    (@tabular.Color::dimmed(), "\u001b[2m", "\u001b[22m"),
    (@tabular.Color::hidden(), "\u001b[8m", "\u001b[28m"),
    (@tabular.Color::invert(), "\u001b[7m", "\u001b[27m"),
    (@tabular.Color::italic(), "\u001b[3m", "\u001b[23m"),
    (@tabular.Color::reset(), "\u001b[0m", "\u001b[0m"),
    (@tabular.Color::strikethrough(), "\u001b[9m", "\u001b[29m"),
    (@tabular.Color::underline(), "\u001b[4m", "\u001b[24m"),
  ]
  for entry in cases {
    assert_eq(entry.0.get_prefix(), entry.1)
    assert_eq(entry.0.get_suffix(), entry.2)
    assert_false(entry.0.is_empty())
  }
}
