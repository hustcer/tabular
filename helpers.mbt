///|
fn convert_align(align : Align) -> @papergrid.HAlign {
  match align {
    Left => @papergrid.HAlign::left()
    Right => @papergrid.HAlign::right()
    Center => @papergrid.HAlign::center()
  }
}

///|
fn convert_valign(align : VAlign) -> @papergrid.VAlign {
  match align {
    Top => @papergrid.VAlign::top()
    Bottom => @papergrid.VAlign::bottom()
    Center => @papergrid.VAlign::center()
  }
}

///|
fn convert_width(width : Width) -> @papergrid.WidthMode {
  match width {
    Wrap(size) => @papergrid.WidthMode::wrap(size)
    Truncate(size, suffix) => @papergrid.WidthMode::truncate(size, suffix)
  }
}

///|
fn convert_height(height : Height) -> @papergrid.HeightMode {
  match height {
    Increase(size) => @papergrid.HeightMode::increase(size)
    Limit(size) => @papergrid.HeightMode::limit(size)
  }
}

///|
fn join_lines(lines : Array[String]) -> String {
  let sb = StringBuilder::new()
  for i, line in lines {
    if i > 0 {
      sb.write_char('\n')
    }
    sb.write_string(line)
  }
  sb.to_string()
}

///|
fn format_content_once(
  value : String,
  format : Format,
  row : Int,
  col : Int,
) -> String {
  match format {
    Surround(prefix, suffix, _) => prefix + value + suffix
    Value(text, _) => text
    Content(transform, _) => transform(value)
    Positioned(transform, _) => transform(value, row, col)
  }
}

///|
fn format_content(
  value : String,
  format : Format,
  row : Int,
  col : Int,
) -> String {
  let multiline = match format {
    Surround(_, _, multiline) => multiline
    Value(_, multiline) => multiline
    Content(_, multiline) => multiline
    Positioned(_, multiline) => multiline
  }
  if !multiline {
    return format_content_once(value, format, row, col)
  }

  let lines = @papergrid.split_lines(value)
  let formatted = []
  lines.each(line => formatted.push(format_content_once(line, format, row, col)))
  join_lines(formatted)
}

///|
fn clamp_start(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
fn clamp_end(value : Int, limit : Int) -> Int {
  if value < 0 || value > limit {
    limit
  } else {
    value
  }
}

///|
fn resolve_indexes(
  start : Int,
  end_ : Int,
  count : Int,
  exclude_start : Int,
  exclude_end : Int,
  skip_n : Int,
  step_n : Int,
) -> Array[Int] {
  let result = []
  if start <= -2 && end_ == 0 {
    let offset = -start - 2
    let index = count - offset - 1
    if index >= 0 && index < count {
      result.push(index)
    }
    return result
  }
  let start_index = clamp_start(start)
  let end_index = clamp_end(end_, count)
  let mut seen = 0
  for index = start_index; index < end_index; index = index + 1 {
    if index >= exclude_start && index < exclude_end {
      continue
    }
    if seen < skip_n {
      seen = seen + 1
      continue
    }
    if step_n <= 1 || (seen - skip_n) % step_n == 0 {
      result.push(index)
    }
    seen = seen + 1
  }
  result
}

///|
fn resolve_rows(rows : Rows, count : Int) -> Array[Int] {
  let indexes = resolve_indexes(
    rows.start,
    rows.end_,
    count,
    rows.exclude_start,
    rows.exclude_end,
    rows.skip_n,
    rows.step_n,
  )
  match rows.predicate {
    Some(predicate) => {
      let filtered = []
      indexes.each(index => if predicate(Row(index)) { filtered.push(index) })
      filtered
    }
    None => indexes
  }
}

///|
fn resolve_cols(cols : Cols, count : Int) -> Array[Int] {
  let indexes = resolve_indexes(
    cols.start,
    cols.end_,
    count,
    cols.exclude_start,
    cols.exclude_end,
    cols.skip_n,
    cols.step_n,
  )
  match cols.predicate {
    Some(predicate) => {
      let filtered = []
      indexes.each(index => if predicate(Col(index)) { filtered.push(index) })
      filtered
    }
    None => indexes
  }
}

///|
fn resolve_cols_by_name(
  rows : Array[Array[String]],
  by_name : ByColName,
) -> Array[Int] {
  if rows.is_empty() {
    return []
  }
  let result = []
  rows[0].eachi((index, value) => {
    if value == by_name.name {
      result.push(index)
    }
  })
  result
}

///|
fn apply_skip_step_to_cells(
  cells : Array[(Int, Int)],
  skip_n : Int,
  step_n : Int,
) -> Array[(Int, Int)] {
  let result = []
  let mut seen = 0
  cells.each(cell => {
    if seen < skip_n {
      seen = seen + 1
    } else {
      if step_n <= 1 || (seen - skip_n) % step_n == 0 {
        result.push(cell)
      }
      seen = seen + 1
    }
  })
  result
}

///|
fn unique_cells(cells : Array[(Int, Int)]) -> Array[(Int, Int)] {
  let result = []
  cells.each(cell => if !result.contains(cell) { result.push(cell) })
  result
}

///|
fn unique_indexes(indexes : Array[Int]) -> Array[Int] {
  let result = []
  indexes.each(index => if !result.contains(index) { result.push(index) })
  result
}

///|
fn sort_indexes_desc(indexes : Array[Int]) -> Array[Int] {
  let result = indexes.copy()
  for i in 0..<result.length() {
    for j = i + 1; j < result.length(); j = j + 1 {
      if result[j] > result[i] {
        let current = result[i]
        result[i] = result[j]
        result[j] = current
      }
    }
  }
  result
}

///|
fn build_identity_map(count : Int) -> Array[Int] {
  let result = Array::make(count, -1)
  for index in 0..<count {
    result[index] = index
  }
  result
}

///|
fn build_extract_map(count : Int, indexes : Array[Int]) -> Array[Int] {
  let result = Array::make(count, -1)
  let mut next = 0
  indexes.each(index => {
    if index >= 0 && index < count && result[index] < 0 {
      result[index] = next
      next = next + 1
    }
  })
  result
}

///|
fn build_remove_map(count : Int, indexes : Array[Int]) -> Array[Int] {
  let removed = unique_indexes(indexes)
  let result = Array::make(count, -1)
  let mut next = 0
  for index in 0..<count {
    if removed.contains(index) {
      continue
    }
    result[index] = next
    next = next + 1
  }
  result
}

///|
fn remove_rows_at(rows : Array[Array[String]], indexes : Array[Int]) -> Unit {
  let unique = unique_indexes(indexes)
  let sorted = sort_indexes_desc(unique)
  sorted.each(index => {
    if index >= 0 && index < rows.length() {
      rows.remove(index) |> ignore
    }
  })
}

///|
fn remove_cols_at(rows : Array[Array[String]], indexes : Array[Int]) -> Unit {
  let unique = unique_indexes(indexes)
  let sorted = sort_indexes_desc(unique)
  rows.each(row => {
    sorted.each(index => {
      if index >= 0 && index < row.length() {
        row.remove(index) |> ignore
      }
    })
  })
}

///|
fn extract_rows_at(
  rows : Array[Array[String]],
  indexes : Array[Int],
) -> Array[Array[String]] {
  let result = []
  indexes.each(index => {
    if index >= 0 && index < rows.length() {
      result.push(rows[index].copy())
    }
  })
  result
}

///|
fn extract_cols_at(
  rows : Array[Array[String]],
  indexes : Array[Int],
) -> Array[Array[String]] {
  let result = []
  rows.each(row => {
    let next = []
    indexes.each(index => {
      if index >= 0 && index < row.length() {
        next.push(row[index])
      }
    })
    result.push(next)
  })
  result
}

///|
fn resolve_segment_cells(
  segment : Segment,
  row_count : Int,
  col_count : Int,
) -> Array[(Int, Int)] {
  let result = []
  let skip_n = segment.skip_n
  let step_n = segment.step_n
  let (row_start, row_end, col_start, col_end) = match segment.kind {
    All => (0, row_count, 0, col_count)
    Range(row_start, row_end, col_start, col_end) =>
      (
        clamp_start(row_start),
        clamp_end(row_end, row_count),
        clamp_start(col_start),
        clamp_end(col_end, col_count),
      )
    RowsOnly(rows) => {
      let row_indexes = resolve_rows(rows, row_count)
      let cells = []
      row_indexes.each(row => {
        for col in 0..<col_count {
          cells.push((row, col))
        }
      })
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    ColsOnly(cols) => {
      let col_indexes = resolve_cols(cols, col_count)
      let cells = []
      for row in 0..<row_count {
        col_indexes.each(col => cells.push((row, col)))
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    CellOnly(cell) => {
      let cells = if cell.row >= 0 &&
        cell.row < row_count &&
        cell.col >= 0 &&
        cell.col < col_count {
        [(cell.row, cell.col)]
      } else {
        []
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    Cross(rows, cols) => {
      let row_indexes = resolve_rows(rows, row_count)
      let col_indexes = resolve_cols(cols, col_count)
      let cells = []
      row_indexes.each(row => col_indexes.each(col => cells.push((row, col))))
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseRows(rows) => {
      let excluded = resolve_rows(rows, row_count)
      let cells = []
      for row in 0..<row_count {
        if excluded.contains(row) {
          continue
        }
        for col in 0..<col_count {
          cells.push((row, col))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseCols(cols) => {
      let excluded = resolve_cols(cols, col_count)
      let cells = []
      for row in 0..<row_count {
        for col in 0..<col_count {
          if excluded.contains(col) {
            continue
          }
          cells.push((row, col))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    InverseCell(cell) => {
      let cells = []
      for row in 0..<row_count {
        for col in 0..<col_count {
          if row == cell.row && col == cell.col {
            continue
          }
          cells.push((row, col))
        }
      }
      return apply_skip_step_to_cells(cells, skip_n, step_n)
    }
    Union2(lhs, rhs) => {
      let lhs_cells = resolve_segment_cells(lhs, row_count, col_count)
      let rhs_cells = resolve_segment_cells(rhs, row_count, col_count)
      return apply_skip_step_to_cells(
        unique_cells(lhs_cells + rhs_cells),
        skip_n,
        step_n,
      )
    }
    Diff2(lhs, rhs) => {
      let lhs_cells = resolve_segment_cells(lhs, row_count, col_count)
      let rhs_cells = resolve_segment_cells(rhs, row_count, col_count)
      let cells = []
      lhs_cells.each(cell => if !rhs_cells.contains(cell) { cells.push(cell) })
      return apply_skip_step_to_cells(unique_cells(cells), skip_n, step_n)
    }
  }
  let mut seen = 0
  for row = row_start; row < row_end; row = row + 1 {
    for col = col_start; col < col_end; col = col + 1 {
      if seen < skip_n {
        seen = seen + 1
        continue
      }
      if step_n <= 1 || (seen - skip_n) % step_n == 0 {
        result.push((row, col))
      }
      seen = seen + 1
    }
  }
  result
}

///|
fn apply_setting_to_row(
  config : @papergrid.SpannedConfig,
  row : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(align) =>
      config.set_align_for_rows(row, row + 1, convert_align(align))
    VAlign(align) =>
      config.set_valign_for_rows(row, row + 1, convert_valign(align))
    Pad(padding) =>
      config.set_padding_for_rows(
        row,
        row + 1,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
    W(width) =>
      config.set_width_mode_for_rows(row, row + 1, convert_width(width))
    H(height) =>
      config.set_height_mode_for_rows(row, row + 1, convert_height(height))
    Fmt(_) => ()
    SpanCol(_) => ()
    SpanRow(_) => ()
  }
}

///|
fn apply_setting_to_col(
  config : @papergrid.SpannedConfig,
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(align) =>
      config.set_align_for_cols(col, col + 1, convert_align(align))
    VAlign(align) =>
      config.set_valign_for_cols(col, col + 1, convert_valign(align))
    Pad(padding) =>
      config.set_padding_for_cols(
        col,
        col + 1,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
    W(width) =>
      config.set_width_mode_for_cols(col, col + 1, convert_width(width))
    H(height) =>
      config.set_height_mode_for_cols(col, col + 1, convert_height(height))
    Fmt(_) => ()
    SpanCol(_) => ()
    SpanRow(_) => ()
  }
}

///|
fn apply_setting_to_cell(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Align(align) => config.set_align_for_cell(row, col, convert_align(align))
    VAlign(align) => config.set_valign_for_cell(row, col, convert_valign(align))
    Pad(padding) =>
      config.set_padding_for_cell(
        row,
        col,
        padding.left,
        padding.right,
        padding.top,
        padding.bottom,
      )
    W(width) => config.set_width_mode_for_cell(row, col, convert_width(width))
    H(height) =>
      config.set_height_mode_for_cell(row, col, convert_height(height))
    Fmt(_) => ()
    SpanCol(_) => ()
    SpanRow(_) => ()
  }
}

///|
fn span_intersects_col(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  span : Int,
) -> Bool {
  let end_ = col + span
  for current = col; current < end_; current = current + 1 {
    if !config.is_cell_visible(row, current) {
      return true
    }
  }
  false
}

///|
fn span_intersects_row(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  span : Int,
) -> Bool {
  let end_ = row + span
  for current = row; current < end_; current = current + 1 {
    if !config.is_cell_visible(current, col) {
      return true
    }
  }
  false
}

///|
fn resolved_span_anchor(
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
) -> (Int, Int) {
  match config.span_anchor_for_source(row, col) {
    Some(anchor) => anchor
    None => (row, col)
  }
}

///|
fn apply_col_span(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  size : Int,
) -> Unit {
  if row < 0 || row >= rows.length() {
    return
  }
  let col_count = @papergrid.IterRecords::new(rows).count_cols()
  if col < 0 || col >= col_count {
    return
  }
  let current_anchor = resolved_span_anchor(config, row, col)
  if (current_anchor.0 == row && current_anchor.1 == col) &&
    !config.is_cell_visible(row, col) {
    return
  }
  if size == 1 {
    config.set_col_span(current_anchor.0, current_anchor.1, 1)
    config.clear_unused_span_source(current_anchor.0, current_anchor.1)
    return
  }
  config.set_col_span(current_anchor.0, current_anchor.1, 1)
  config.clear_unused_span_source(current_anchor.0, current_anchor.1)

  let start = if size > 1 {
    col
  } else if size == 0 {
    0
  } else {
    let normalized = col + size
    if normalized < 0 {
      0
    } else {
      normalized
    }
  }
  let span = if size > 1 {
    if start + size > col_count {
      col_count - start
    } else {
      size
    }
  } else if size == 0 {
    col_count - start
  } else {
    col - start + 1
  }
  if span <= 1 || span_intersects_col(config, row, start, span) {
    return
  }
  config.set_col_span(row, start, span)
  config.set_span_source(row, start, row, col)
}

///|
fn apply_row_span(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  size : Int,
) -> Unit {
  if rows.is_empty() || row < 0 || row >= rows.length() {
    return
  }
  let col_count = @papergrid.IterRecords::new(rows).count_cols()
  if col < 0 || col >= col_count {
    return
  }
  let current_anchor = resolved_span_anchor(config, row, col)
  if (current_anchor.0 == row && current_anchor.1 == col) &&
    !config.is_cell_visible(row, col) {
    return
  }
  if size == 1 {
    config.set_row_span(current_anchor.0, current_anchor.1, 1)
    config.clear_unused_span_source(current_anchor.0, current_anchor.1)
    return
  }
  config.set_row_span(current_anchor.0, current_anchor.1, 1)
  config.clear_unused_span_source(current_anchor.0, current_anchor.1)

  let start = if size > 1 {
    row
  } else if size == 0 {
    0
  } else {
    let normalized = row + size
    if normalized < 0 {
      0
    } else {
      normalized
    }
  }
  let span = if size > 1 {
    if row + size > rows.length() {
      rows.length() - start
    } else {
      size
    }
  } else if size == 0 {
    rows.length() - start
  } else {
    row - start + 1
  }
  if span <= 1 || span_intersects_row(config, start, col, span) {
    return
  }
  config.set_row_span(start, col, span)
  config.set_span_source(start, col, row, col)
}

///|
fn apply_format_to_cell(
  rows : Array[Array[String]],
  row : Int,
  col : Int,
  format : Format,
) -> Unit {
  if row < 0 || row >= rows.length() {
    return
  }
  let row_values = rows[row]
  if col < 0 || col >= row_values.length() {
    return
  }
  row_values[col] = format_content(row_values[col], format, row, col)
}

///|
fn apply_setting_to_row_values(
  rows : Array[Array[String]],
  row : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Fmt(format) =>
      if row >= 0 && row < rows.length() {
        let row_values = rows[row]
        for col in 0..<row_values.length() {
          apply_format_to_cell(rows, row, col, format)
        }
      }
    W(_) => ()
    H(_) => ()
    _ => ()
  }
}

///|
fn apply_setting_to_col_values(
  rows : Array[Array[String]],
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Fmt(format) =>
      for row in 0..<rows.length() {
        apply_format_to_cell(rows, row, col, format)
      }
    W(_) => ()
    H(_) => ()
    _ => ()
  }
}

///|
fn apply_setting_to_cell_value(
  rows : Array[Array[String]],
  config : @papergrid.SpannedConfig,
  row : Int,
  col : Int,
  setting : Setting,
) -> Unit {
  match setting {
    Fmt(format) => apply_format_to_cell(rows, row, col, format)
    W(_) => ()
    H(_) => ()
    SpanCol(size) => apply_col_span(rows, config, row, col, size)
    SpanRow(size) => apply_row_span(rows, config, row, col, size)
    _ => ()
  }
}

///|
fn normalize_rows(
  rows : Array[Array[String]],
  empty_cell : String,
) -> Array[Array[String]] {
  let mut max_cols = 0
  rows.each(row => if row.length() > max_cols { max_cols = row.length() })

  rows.map(row => {
    let normalized = []
    for col in 0..<max_cols {
      if col < row.length() {
        normalized.push(row[col])
      } else {
        normalized.push(empty_cell)
      }
    }
    normalized
  })
}

///|
/// Create an IndexBuilder from this Builder for index/transpose operations.
pub fn Builder::index(self : Builder) -> IndexBuilder {
  {
    rows: self.rows,
    empty_cell: self.empty_cell,
    index_col: None,
    index_name: Some(""),
    show_index: true,
  }
}

///|
/// Use the specified col as the index col (0-based).
pub fn IndexBuilder::col(self : IndexBuilder, col : Int) -> IndexBuilder {
  self.index_col = Some(col)
  self
}

///|
/// Set the name for the index col. None removes the name row.
pub fn IndexBuilder::name(self : IndexBuilder, name : String?) -> IndexBuilder {
  self.index_name = name
  self
}

///|
/// Hide the index col.
pub fn IndexBuilder::hide(self : IndexBuilder) -> IndexBuilder {
  self.show_index = false
  self
}

///|
/// Transpose the table (swap rows and cols).
pub fn IndexBuilder::transpose(self : IndexBuilder) -> IndexBuilder {
  let norm = normalize_rows(self.rows, self.empty_cell)
  let row_count = norm.length()
  let col_count = if row_count > 0 { norm[0].length() } else { 0 }
  if row_count == 0 || col_count == 0 {
    return self
  }
  // After transpose, first col = original headers (row 0 values),
  // remaining cols = original data rows, new header = row indices
  let result : Array[Array[String]] = []
  // Header row: empty + original row indices
  let header : Array[String] = [""]
  for r = 1; r < row_count; r = r + 1 {
    header.push((r - 1).to_string())
  }
  result.push(header)
  // Each original col becomes a data row
  for c in 0..<col_count {
    let new_row : Array[String] = []
    for r in 0..<row_count {
      new_row.push(norm[r][c])
    }
    result.push(new_row)
  }
  self.rows.clear()
  result.each(row => self.rows.push(row))
  // After transpose, index is already baked in; disable further index processing
  self.show_index = false
  self
}

///|
/// Build the final Table from the IndexBuilder.
pub fn IndexBuilder::build(self : IndexBuilder) -> Table {
  let norm = normalize_rows(self.rows, self.empty_cell)
  let row_count = norm.length()
  let col_count = if row_count > 0 { norm[0].length() } else { 0 }
  if row_count == 0 || col_count == 0 {
    return Table::from_rows(norm)
  }
  match self.index_col {
    None => {
      // Default: add a numeric index col at position 0
      if not(self.show_index) {
        return Table::from_rows(norm)
      }
      let result : Array[Array[String]] = []
      for i in 0..<row_count {
        let row : Array[String] = []
        if i == 0 {
          // Header row: index name or empty
          row.push(self.index_name.unwrap_or(""))
        } else {
          row.push((i - 1).to_string())
        }
        norm[i].each(cell => row.push(cell))
        result.push(row)
      }
      Table::from_rows(result)
    }
    Some(col_idx) => {
      // Use specified col as index, move it to position 0
      if col_idx >= col_count {
        return Table::from_rows(norm)
      }
      let result : Array[Array[String]] = []
      // First row: header with index name
      let header_row : Array[String] = []
      header_row.push("")
      for c in 0..<col_count {
        if c != col_idx {
          header_row.push(if row_count > 0 { norm[0][c] } else { "" })
        }
      }
      result.push(header_row)
      // Index name row (if set)
      match self.index_name {
        Some(name) => {
          let name_row : Array[String] = Array::make(col_count, "")
          name_row[0] = if name == "" { norm[0][col_idx] } else { name }
          result.push(name_row)
        }
        None => ()
      }
      // Data rows: use col value as index
      for r = 1; r < row_count; r = r + 1 {
        let data_row : Array[String] = []
        data_row.push(norm[r][col_idx])
        for c in 0..<col_count {
          if c != col_idx {
            data_row.push(norm[r][c])
          }
        }
        result.push(data_row)
      }
      Table::from_rows(result)
    }
  }
}

///|
/// Apply a Split setting to reshape the table.
/// This resets config (spans, borders) since Split fundamentally changes the table shape.
pub fn Table::split(self : Table, split : Split) -> Table {
  let section_length = split.index
  let count_rows = self.rows.length()
  let count_cols = if count_rows > 0 { self.rows[0].length() } else { 0 }
  // Early return for empty table or zero index
  if count_cols == 0 || count_rows == 0 || section_length == 0 {
    return self
  }
  let (primary_length, secondary_length) = match split.direction {
    SplitCol => (count_cols, count_rows)
    SplitRow => (count_rows, count_cols)
  }
  let sections_per_direction = split_ceil_div(primary_length, section_length)
  let (outer_start, outer_end, inner_start, inner_end) = match split.behavior {
    SplitConcat => (1, sections_per_direction, 0, secondary_length)
    SplitZip => (0, secondary_length, 1, sections_per_direction)
  }
  let mut filtered_sections = 0
  for outer_index = outer_start
      outer_index < outer_end
      outer_index = outer_index + 1 {
    let from_secondary_index = outer_index * sections_per_direction -
      filtered_sections
    for inner_index = inner_start
        inner_index < inner_end
        inner_index = inner_index + 1 {
      let (section_index, from_sec, to_sec) = match split.behavior {
        SplitConcat => {
          let si = outer_index
          let fs = inner_index
          let ts = inner_index +
            outer_index * secondary_length -
            filtered_sections
          (si, fs, ts)
        }
        SplitZip => {
          let si = inner_index
          let fs = from_secondary_index
          let ts = outer_index * sections_per_direction +
            inner_index -
            filtered_sections
          (si, fs, ts)
        }
      }
      // Insert new row/col
      match (split.direction, split.behavior) {
        (SplitCol, SplitConcat) => split_push_row(self.rows)
        (SplitCol, SplitZip) => split_insert_row(self.rows, to_sec)
        (SplitRow, SplitConcat) => split_push_col(self.rows)
        (SplitRow, SplitZip) => split_insert_col(self.rows, to_sec)
      }
      // Copy cells from overflow position to new position
      let section_is_empty = split_copy_section(
        self.rows,
        section_length,
        section_index,
        primary_length,
        from_sec,
        to_sec,
        split.direction,
      )
      // If section is empty and display is Clean, delete the inserted row/col
      if section_is_empty && split.display == SplitClean {
        match split.direction {
          SplitCol => split_remove_row(self.rows, to_sec)
          SplitRow => split_remove_col(self.rows, to_sec)
        }
        filtered_sections = filtered_sections + 1
      }
    }
  }
  // Cleanup: remove extra cols/rows beyond section_length
  for segment = primary_length - 1
      segment >= section_length
      segment = segment - 1 {
    match split.direction {
      SplitCol => split_remove_col(self.rows, segment)
      SplitRow => split_remove_row(self.rows, segment)
    }
  }
  // Clear spans and border overrides since the table shape changed completely
  self.config.clear_spans_and_overrides()
  self
}
