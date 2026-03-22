///|
pub struct Table {
  mut rows : Array[Array[String]]
  config : @papergrid.SpannedConfig
}

///|
pub fn Table::from_rows(rows : Array[Array[String]]) -> Table {
  { rows, config: @papergrid.SpannedConfig::default() }
}

///|
pub fn Table::apply(self : Table, style : Style) -> Table {
  self.config.set_borders(style.borders())
  self.config.set_horizontal_lines(style.horizontal_lines())
  self.config.set_custom_horizontal_lines(style.custom_horizontal_lines())
  self
}

///|
pub fn Table::set_align(self : Table, align : Align) -> Table {
  self.config.set_align(convert_align(align))
  self
}

///|
pub fn Table::set_valign(self : Table, align : VAlign) -> Table {
  self.config.set_valign(convert_valign(align))
  self
}

///|
pub fn Table::set_padding(self : Table, padding : Padding) -> Table {
  self.config.set_padding(
    padding.left,
    padding.right,
    padding.top,
    padding.bottom,
  )
  self
}

///|
pub fn Table::set_width(self : Table, width : Width) -> Table {
  self.config.set_width_mode(convert_width(width))
  self
}

///|
pub fn Table::set_height(self : Table, height : Height) -> Table {
  self.config.set_height_mode(convert_height(height))
  self
}

///|
pub fn Table::to_string(self : Table) -> String {
  let records = @papergrid.IterRecords::new(self.rows)
  let dims = @papergrid.IterGridDimension::default()
  dims.estimate(records, self.config)
  let grid = @papergrid.IterGrid::new(records, self.config, dims)
  grid.to_string()
}

///|
pub fn Table::modify_rows(
  self : Table,
  rows : Rows,
  setting : Setting,
) -> Table {
  let row_indexes = resolve_rows(rows, self.rows.length())
  if setting is SpanCol(_) || setting is SpanRow(_) {
    let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
    row_indexes.each(row => {
      for col in 0..<col_count {
        apply_setting_to_cell_value(self.rows, self.config, row, col, setting)
      }
    })
  } else {
    row_indexes.each(row => {
      apply_setting_to_row_values(self.rows, row, setting)
      apply_setting_to_row(self.config, row, setting)
    })
  }
  self
}

///|
pub fn Table::modify_cols(
  self : Table,
  cols : Cols,
  setting : Setting,
) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let col_indexes = resolve_cols(cols, col_count)
  if setting is SpanCol(_) || setting is SpanRow(_) {
    for row in 0..<self.rows.length() {
      col_indexes.each(col => {
        apply_setting_to_cell_value(self.rows, self.config, row, col, setting)
      })
    }
  } else {
    col_indexes.each(col => {
      apply_setting_to_col_values(self.rows, col, setting)
      apply_setting_to_col(self.config, col, setting)
    })
  }
  self
}

///|
pub fn Table::modify_segment(
  self : Table,
  segment : Segment,
  setting : Setting,
) -> Table {
  match (segment.kind, segment.skip_n, segment.step_n) {
    (All, 0, 1) =>
      match setting {
        Align(align) => self.config.set_align_for_all(convert_align(align))
        VAlign(align) => self.config.set_valign_for_all(convert_valign(align))
        Pad(padding) =>
          self.config.set_padding_for_all(
            padding.left,
            padding.right,
            padding.top,
            padding.bottom,
          )
        W(width) => self.config.set_width_mode_for_all(convert_width(width))
        H(height) => self.config.set_height_mode_for_all(convert_height(height))
        Fmt(format) =>
          for row in 0..<self.rows.length() {
            let row_values = self.rows[row]
            for col in 0..<row_values.length() {
              apply_format_to_cell(self.rows, row, col, format)
            }
          }
        SpanCol(_) => {
          let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
          for row in 0..<self.rows.length() {
            for col in 0..<col_count {
              apply_setting_to_cell_value(
                self.rows,
                self.config,
                row,
                col,
                setting,
              )
            }
          }
        }
        SpanRow(_) => {
          let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
          for row in 0..<self.rows.length() {
            for col in 0..<col_count {
              apply_setting_to_cell_value(
                self.rows,
                self.config,
                row,
                col,
                setting,
              )
            }
          }
        }
      }
    _ => {
      let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
      resolve_segment_cells(segment, self.rows.length(), col_count).each(cell => {
        apply_setting_to_cell_value(
          self.rows,
          self.config,
          cell.0,
          cell.1,
          setting,
        )
        apply_setting_to_cell(self.config, cell.0, cell.1, setting)
      })
    }
  }
  self
}

///|
pub fn Table::modify_cell(
  self : Table,
  cell : Cell,
  setting : Setting,
) -> Table {
  apply_setting_to_cell_value(
    self.rows,
    self.config,
    cell.row,
    cell.col,
    setting,
  )
  apply_setting_to_cell(self.config, cell.row, cell.col, setting)
  self
}

///|
pub fn Table::modify_by_col_name(
  self : Table,
  by_name : ByColName,
  setting : Setting,
) -> Table {
  resolve_cols_by_name(self.rows, by_name).each(col => {
    self.modify_cols(Cols::one(col), setting) |> ignore
  })
  self
}

///|
pub fn Table::remove_rows(self : Table, rows : Rows) -> Table {
  let indexes = resolve_rows(rows, self.rows.length())
  let row_map = build_remove_map(self.rows.length(), indexes)
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  remove_rows_at(self.rows, indexes)
  self.config.remap(row_map, build_identity_map(col_count))
  self
}

///|
pub fn Table::remove_cols(self : Table, cols : Cols) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let indexes = resolve_cols(cols, col_count)
  let col_map = build_remove_map(col_count, indexes)
  remove_cols_at(self.rows, indexes)
  self.config.remap(build_identity_map(self.rows.length()), col_map)
  self
}

///|
pub fn Table::remove_by_col_name(self : Table, by_name : ByColName) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let indexes = resolve_cols_by_name(self.rows, by_name)
  let col_map = build_remove_map(col_count, indexes)
  remove_cols_at(self.rows, indexes)
  self.config.remap(build_identity_map(self.rows.length()), col_map)
  self
}

///|
pub fn Table::extract_rows(self : Table, rows : Rows) -> Table {
  let indexes = resolve_rows(rows, self.rows.length())
  let row_map = build_extract_map(self.rows.length(), indexes)
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  self.rows = extract_rows_at(self.rows, indexes)
  self.config.remap(row_map, build_identity_map(col_count))
  self
}

///|
pub fn Table::extract_cols(self : Table, cols : Cols) -> Table {
  let col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let indexes = resolve_cols(cols, col_count)
  let col_map = build_extract_map(col_count, indexes)
  self.rows = extract_cols_at(self.rows, indexes)
  self.config.remap(build_identity_map(self.rows.length()), col_map)
  self
}

///|
pub fn Table::extract_segment(self : Table, rows : Rows, cols : Cols) -> Table {
  let row_indexes = resolve_rows(rows, self.rows.length())
  let row_map = build_extract_map(self.rows.length(), row_indexes)
  let extracted_rows = extract_rows_at(self.rows, row_indexes)
  let original_col_count = @papergrid.IterRecords::new(self.rows).count_cols()
  let col_indexes = resolve_cols(cols, original_col_count)
  let col_map = build_extract_map(original_col_count, col_indexes)
  self.rows = extract_cols_at(extracted_rows, col_indexes)
  self.config.remap(row_map, col_map)
  self
}
