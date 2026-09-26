///|
// Reference values from ansitok 0.3.0 / vte 0.14.1 via the pinned Rust probe.
test "DEL remains in the text token before an escape sequence" {
  for sequence in ["\u001b[31m", "\u001b[0m", "\u001b[?1m", "\u001b\\"] {
    let text = "a\u007f" + sequence + "b"
    assert_eq(@papergrid.get_line_width(text), 3)
    assert_eq(@papergrid.strip_ansi(text), "a\u007fb")
    assert_eq(@papergrid.trim_ansi_whitespace(text), text)
  }
  for sequence in ["\u001b", "\u001b[", "\u001b]url", "\u001bPabc"] {
    let text = "a\u007f" + sequence + "b"
    assert_eq(@papergrid.get_line_width(text), 2)
    assert_eq(@papergrid.strip_ansi(text), "a\u007f")
    assert_eq(@papergrid.trim_ansi_whitespace(text), text)
  }
  let link = "a\u007f\u001b]8;;u\u001b\\b"
  assert_eq(@papergrid.get_line_width(link), 3)
  assert_eq(@papergrid.strip_ansi(link), "a\u007fb")
  assert_eq(@papergrid.trim_ansi_whitespace(link), link)
}

///|
test "OSC cancellation emits the pending control token" {
  for cancel in ['\u0018', '\u001a'] {
    let text = "a\u001b]url" + cancel.to_string() + "b"
    assert_eq(@papergrid.get_line_width(text), 3)
    assert_eq(@papergrid.strip_ansi(text), "a\u001bb")
    assert_eq(@papergrid.trim_ansi_whitespace(text), text)
  }
}

///|
test "DCS string terminator returns the parser to ground" {
  for terminator in ["\u009c", "Ü", "М", "ܜ"] {
    let text = "a\u001bPabc" + terminator + "b"
    assert_eq(@papergrid.get_line_width(text), 8)
    assert_eq(@papergrid.strip_ansi(text), text)
    assert_eq(@papergrid.trim_ansi_whitespace(text), text)
  }
}
