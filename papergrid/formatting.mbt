///|
/// Rendering-only whitespace and multiline alignment policy.
pub(all) struct Formatting {
  trim_horizontal : Bool
  trim_vertical : Bool
  align_lines : Bool
} derive(Eq, Debug)

///|
pub fn Formatting::new(
  trim_horizontal~ : Bool,
  trim_vertical~ : Bool,
  align_lines~ : Bool,
) -> Formatting {
  { trim_horizontal, trim_vertical, align_lines, }
}

///|
pub fn Formatting::default() -> Formatting {
  Formatting::new(trim_horizontal=false, trim_vertical=false, align_lines=false)
}

///|
/// An ANSI prefix and suffix, kept separate from the visible cell text.
pub(all) struct ANSIBuf {
  prefix : String
  suffix : String
} derive(Eq, Debug)

///|
pub fn ANSIBuf::new(prefix : String, suffix : String) -> ANSIBuf {
  { prefix, suffix, }
}

///|
pub fn ANSIBuf::empty() -> ANSIBuf {
  ANSIBuf::new("", "")
}

///|
pub fn ANSIBuf::is_empty(self : ANSIBuf) -> Bool {
  self.prefix.is_empty() && self.suffix.is_empty()
}

///|
pub fn ANSIBuf::get_prefix(self : ANSIBuf) -> String {
  self.prefix
}

///|
pub fn ANSIBuf::get_suffix(self : ANSIBuf) -> String {
  self.suffix
}

///|
priv enum FormatChange {
  HorizontalTrim(Bool)
  VerticalTrim(Bool)
  LineAlignment(Bool)
  AlignmentFill(Char, ANSIBuf?)
  TextColor(ANSIBuf?)
}

///|
priv struct TextFormat {
  mut formatting : Formatting
  mut justification : Char
  mut justification_color : ANSIBuf?
  mut color : ANSIBuf?
}

///|
fn entity_scope(entity : Entity) -> Scope {
  match entity {
    Global => All
    Row(row) => RowRange(row, if row == 2147483647 { row } else { row + 1 })
    Col(col) => ColRange(col, if col == 2147483647 { col } else { col + 1 })
    Cell(row, col) => Cell(row, col)
  }
}

///|
pub fn SpannedConfig::set_trim_horizontal(
  self : SpannedConfig,
  entity : Entity,
  enabled : Bool,
) -> Unit {
  self.formatting_rules.push((entity_scope(entity), HorizontalTrim(enabled)))
}

///|
pub fn SpannedConfig::set_trim_vertical(
  self : SpannedConfig,
  entity : Entity,
  enabled : Bool,
) -> Unit {
  self.formatting_rules.push((entity_scope(entity), VerticalTrim(enabled)))
}

///|
pub fn SpannedConfig::set_line_alignment(
  self : SpannedConfig,
  entity : Entity,
  enabled : Bool,
) -> Unit {
  self.formatting_rules.push((entity_scope(entity), LineAlignment(enabled)))
}

///|
pub fn SpannedConfig::set_formatting(
  self : SpannedConfig,
  entity : Entity,
  formatting : Formatting,
) -> Unit {
  self.set_trim_horizontal(entity, formatting.trim_horizontal)
  self.set_trim_vertical(entity, formatting.trim_vertical)
  self.set_line_alignment(entity, formatting.align_lines)
}

///|
pub fn SpannedConfig::set_alignment_fill(
  self : SpannedConfig,
  entity : Entity,
  fill : Char,
  color? : ANSIBuf,
) -> Unit {
  self.formatting_rules.push((entity_scope(entity), AlignmentFill(fill, color)))
}

///|
pub fn SpannedConfig::set_color(
  self : SpannedConfig,
  entity : Entity,
  color : ANSIBuf?,
) -> Unit {
  self.formatting_rules.push((entity_scope(entity), TextColor(color)))
}

///|
fn SpannedConfig::text_format_at(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> TextFormat {
  let result = TextFormat::{
    formatting: Formatting::default(),
    justification: ' ',
    justification_color: None,
    color: None,
  }
  for rule in self.formatting_rules {
    if scope_matches(rule.0, row, col) {
      match rule.1 {
        HorizontalTrim(enabled) =>
          result.formatting = { ..result.formatting, trim_horizontal: enabled, }
        VerticalTrim(enabled) =>
          result.formatting = { ..result.formatting, trim_vertical: enabled, }
        LineAlignment(enabled) =>
          result.formatting = { ..result.formatting, align_lines: enabled, }
        AlignmentFill(fill, color) => {
          result.justification = fill
          result.justification_color = color
        }
        TextColor(color) => result.color = color
      }
    }
  }
  result
}

///|
pub fn SpannedConfig::get_formatting(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Formatting {
  self.text_format_at(row, col).formatting
}

///|
pub fn SpannedConfig::get_alignment_fill(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> Char {
  self.text_format_at(row, col).justification
}

///|
pub fn SpannedConfig::get_alignment_fill_color(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> ANSIBuf? {
  self.text_format_at(row, col).justification_color
}

///|
pub fn SpannedConfig::get_color(
  self : SpannedConfig,
  row : Int,
  col : Int,
) -> ANSIBuf? {
  self.text_format_at(row, col).color
}

///|
fn SpannedConfig::remap_formatting(
  self : SpannedConfig,
  row_map : Array[Int],
  col_map : Array[Int],
) -> Unit {
  let rules = []
  for rule in self.formatting_rules {
    match rule.0 {
      RowRange(start, end_) =>
        mapped_runs(row_map, start, end_).each(run => {
          rules.push((RowRange(run.0, run.1), rule.1))
        })
      ColRange(start, end_) =>
        mapped_runs(col_map, start, end_).each(run => {
          rules.push((ColRange(run.0, run.1), rule.1))
        })
      All => rules.push(rule)
      Cell(row, col) => {
        let row = map_index(row_map, row)
        let col = map_index(col_map, col)
        if row >= 0 && col >= 0 {
          rules.push((Cell(row, col), rule.1))
        }
      }
    }
  }
  self.formatting_rules.clear()
  self.formatting_rules.append(rules)
}
