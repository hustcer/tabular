///|
/// A pair of ANSI sequences with the borrowed-style API used by papergrid.
/// MoonBit strings are shared immutable values, so no explicit lifetime is needed.
pub(all) struct ANSIStr {
  prefix : String
  suffix : String
} derive(Eq, Debug)

///|
pub fn ANSIStr::new(prefix : String, suffix : String) -> ANSIStr {
  { prefix, suffix, }
}

///|
pub fn ANSIStr::empty() -> ANSIStr {
  ANSIStr::new("", "")
}

///|
pub fn ANSIStr::default() -> ANSIStr {
  ANSIStr::empty()
}

///|
pub fn ANSIStr::is_empty(self : ANSIStr) -> Bool {
  self.prefix.is_empty() && self.suffix.is_empty()
}

///|
pub fn ANSIStr::get_prefix(self : ANSIStr) -> String {
  self.prefix
}

///|
pub fn ANSIStr::get_suffix(self : ANSIStr) -> String {
  self.suffix
}

///|
pub fn ANSIBuf::as_ref(self : ANSIBuf) -> ANSIStr {
  ANSIStr::new(self.prefix, self.suffix)
}

///|
pub fn ANSIBuf::from_ansi_str(value : ANSIStr) -> ANSIBuf {
  ANSIBuf::new(value.prefix, value.suffix)
}

///|
pub fn ANSIBuf::default() -> ANSIBuf {
  ANSIBuf::empty()
}

///|
/// Write ANSI style boundaries independently of the text being formatted.
pub(open) trait ANSIFmt {
  fn fmt_ansi_prefix(Self, StringBuilder) -> Unit
  fn fmt_ansi_suffix(Self, StringBuilder) -> Unit
}

///|
pub impl ANSIFmt for ANSIBuf with fn fmt_ansi_prefix(self, out) {
  out.write_string(self.prefix)
}

///|
pub impl ANSIFmt for ANSIBuf with fn fmt_ansi_suffix(self, out) {
  out.write_string(self.suffix)
}

///|
pub impl ANSIFmt for ANSIStr with fn fmt_ansi_prefix(self, out) {
  out.write_string(self.prefix)
}

///|
pub impl ANSIFmt for ANSIStr with fn fmt_ansi_suffix(self, out) {
  out.write_string(self.suffix)
}
