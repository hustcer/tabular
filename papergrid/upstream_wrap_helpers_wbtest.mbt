///|
fn upstream_wrap_words(text : String, width : Int) -> String {
  wrap_words(text, width, "", "")
}

///|
fn String::upstream_ansi_lines(self : String) -> Array[String] {
  get_lines(self)
}
