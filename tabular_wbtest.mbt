///|
test "style exposes borders" {
  let style = Style::modern()
  guard style.borders().top_left is Some('┌') else {
    fail("expected modern style to expose top-left border")
  }
}
