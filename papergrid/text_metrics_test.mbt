///|
test "line endings follow the distinct upstream width and dimension APIs" {
  assert_eq(get_text_width("abc\r\nxy\r\n"), 3)
  assert_eq(get_text_width("abc\r"), 4)
  assert_eq(get_text_width("abc\r\r\n"), 4)
  assert_eq(get_text_dimension("abc\r\n"), (2, 4))
  assert_eq(get_string_width("\r\n"), 1)
  assert_eq(get_char_width('\n'), 0)
  assert_eq(count_lines("\r\n"), 2)
}

///|
test "tab replacement preserves the upstream escaped-tab fast-path difference" {
  assert_eq(count_tabs("\\\t\ttext\\t"), 2)
  assert_eq(replace_tab("\\\t\ttext", 4), "\\        text")
  assert_eq(replace_tab("\\\t\ttext", 3), "\\\t   text")
  assert_eq(replace_tab("\\\t\ttext", 0), "\\\ttext")
  assert_eq(replace_tab("界\t文", 2), "界  文")
}

///|
test "ANSI tokens delimit Unicode presentation sequences as in papergrid" {
  assert_eq(get_line_width("👩‍🔬"), 2)
  assert_eq(get_line_width("👩\u001b[31m‍🔬\u001b[0m"), 4)
  assert_eq(get_line_width("\u001b[31m👩‍🔬\u001b[0m"), 2)
  assert_eq(get_line_width("👍🏿"), 2)
  assert_eq(cut_str("👍🏿", 3), "👍�")
}
