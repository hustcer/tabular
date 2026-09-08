///|
fn[T : ANSIFmt] ansi_format(style : T, text : String) -> String {
  let out = StringBuilder()
  style.fmt_ansi_prefix(out)
  out.write_string(text)
  style.fmt_ansi_suffix(out)
  out.to_string()
}

///|
test "ANSI borrowed and owned style conversions preserve formatting" {
  let style = ANSIStr::new("\u001b[31m", "\u001b[39m")
  assert_eq(style.get_prefix(), "\u001b[31m")
  assert_eq(style.get_suffix(), "\u001b[39m")
  assert_false(style.is_empty())
  let owned = ANSIBuf::from_ansi_str(style)
  assert_eq(owned.as_ref(), style)
  assert_eq(ansi_format(style, "red"), "\u001b[31mred\u001b[39m")
  assert_eq(ansi_format(owned, "red"), ansi_format(style, "red"))
  assert_true(ANSIStr::default().is_empty())
  assert_eq(ANSIBuf::default().as_ref(), ANSIStr::empty())
}

///|
test "width modes retain colors across wrapping and suffix truncation" {
  let red = "\u001b[31mabcdef\u001b[39m"
  assert_eq(apply_width(red, WidthMode::wrap(3)), [
    "\u001b[31mabc\u001b[39m", "\u001b[31mdef\u001b[39m",
  ])
  assert_eq(apply_width(red, WidthMode::truncate(4, "..")), [
    "\u001b[31mab\u001b[39m..",
  ])
  assert_eq(apply_width("中", WidthMode::wrap(1)), ["�"])
  assert_eq(apply_width("中", WidthMode::truncate(1, "")), ["�"])
}

///|
test "width modes preserve multiline hyperlink boundaries" {
  let start = "\u001b]8;;https://example.com\u001b\\"
  let end_ = "\u001b]8;;\u001b\\"
  assert_eq(apply_width(start + "abcd\nefgh" + end_, WidthMode::wrap(2)), [
    start + "ab" + end_,
    start + "cd" + end_,
    start + "ef" + end_,
    start + "gh" + end_,
  ])
}
