///|
// Upstream: papergrid/src/util/string.rs::tests::string_width_emojie_test
test "upstream text string_width_emojie_test" {
  assert_eq(get_line_width("🎩"), 2)
  assert_eq(get_line_width("Rust 💕"), 7)
  assert_eq(get_text_width("Go 👍\nC 😎"), 5)
}

///|
// Upstream: papergrid/src/util/string.rs::tests::colored_string_width_test
test "upstream text colored_string_width_test" {
  assert_eq(get_line_width("\u001b[34mhello world\u001b[0m"), 11)
  assert_eq(
    get_text_width("\u001b[34mhello\u001b[0m\n\u001b[34mworld\u001b[0m"),
    5,
  )
  assert_eq(get_line_width("\u001b[34m0\u001b[0m"), 1)
  assert_eq(get_line_width("\u001b[34m\u001b[34m\u001b[34m0\u001b[0m"), 1)
}

///|
// Upstream: papergrid/src/util/string.rs::tests::count_lines_test
test "upstream text count_lines_test" {
  assert_eq(
    count_lines("\u001b[37mnow is the time for all good men\n\u001b[0m"),
    2,
  )
  assert_eq(count_lines("now is the time for all good men\n"), 2)
}

///|
// Upstream: papergrid/src/util/string.rs::tests::string_width_multinline_for_link
test "upstream text string_width_multinline_for_link" {
  assert_eq(
    get_text_width(
      "\u001b]8;;file:///home/nushell/asd.zip\u001b\\asd.zip\u001b]8;;\u001b\\",
    ),
    7,
  )
}

///|
// Upstream: papergrid/src/util/string.rs::tests::string_width_for_link
test "upstream text string_width_for_link" {
  assert_eq(
    get_line_width(
      "\u001b]8;;file:///home/nushell/asd.zip\u001b\\asd.zip\u001b]8;;\u001b\\",
    ),
    7,
  )
}

///|
// Upstream: papergrid/src/util/string.rs::tests::string_dimension_test
test "upstream text string_dimension_test" {
  assert_eq(
    get_text_dimension("\u001b[37mnow is the time for all good men\n\u001b[0m"),
    (2, 32),
  )
  assert_eq(get_text_dimension("now is the time for all good men\n"), (2, 32))
  assert_eq(get_text_dimension("asd"), (1, 3))
  assert_eq(get_text_dimension(""), (1, 0))
}
