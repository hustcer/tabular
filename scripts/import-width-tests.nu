#!/usr/bin/env nu
# Preserve every upstream width test_table! case and its literal expectations.
use upstream-literals.nu [expected-lines decode-rust-string]
use import-transform-tests.nu translate

def width-expression [expression: string]: nothing -> string {
  let owned = $expression =~ 'colorize|let data'
  let expr = ($expression
    | str replace --all --regex '(?m)^\s*//[^\n]*' ''
    | str replace --all 'Matrix::iter(Vec::<usize>::new())' 'upstream_width_strings([], "usize")'
    | str replace --all --regex '(?s)Matrix::iter\(\s*(\[\s*\[.*?\]\s*,?\s*\])\s*\)' 'upstream_width_arrays($1).set_align(@tabular.Align::center())'
    | str replace --all --regex 'Table::new\(vec!(\[\[.*?\]\])\)' 'upstream_width_arrays($1)'
    | str replace --all --regex '(?s)Matrix::iter\(\s*&?(?:vec!)?(\[.*?\])\s*\)' {|values|
        let header = if $owned { 'String' } else { '&str' }
        'upstream_width_strings(' + $values + ', "' + $header + '").set_align(@tabular.Align::center())'
      }
    | str replace --all 'Matrix::iter(data)' 'upstream_width_strings(data, "String").set_align(@tabular.Align::center())'
    | str replace --all '.not(Rows::' '.not_rows(Rows::'
    | str replace --all 'Columns::new(1..2)' 'Columns::new(1, 2)'
    | str replace --all 'Columns::new(..)' 'Columns::all()'
    | str replace --all --regex 'assert_width!\(&?(\w+),\s*([^;]+)\);' 'upstream_assert_width($1, $2)'
    | str replace --all --regex 'AnsiStr::ansi_strip\(&?(\w+)\)' '@papergrid.strip_ansi($1)'
    | str replace --all 'let data = &[' 'let data = ['
    | str replace --all 'vec![' '['
    | str replace --all '.with(Panel::' '.panel(Panel::'
    | str replace --all 'HorizontalLine::inherit(' 'HorizontalLine::from_style(')
  translate $expr
    | str replace --all --regex '(?<![\w.])(Width|Truncate|Wrap|MinWidth|Justify|SuffixLimit|PriorityLeft|PriorityRight|PriorityMin|PriorityMax|HorizontalLine|Panel|Margin)::' '@tabular.$1::'
    | str replace --all --regex 'upstream_string_table\(data\)' 'upstream_width_strings(data, "String")'
}

def derived-tests [source: string]: nothing -> string {
  let names = [wrapping_as_total_multiline wrapping_as_total_multiline_color truncating_as_total_multiline_color hyperlinks hyperlinks_with_color hyperlinks_truncate hyperlinks_colored_truncate]
  $names | each {|name|
    let body = ($source | split row $'fn ($name)()' | get 1 | split row '    #[test]' | first)
    let pattern = '(?s)(?:assert_eq!|assert_table!)\(\s*(?:table|table\(&text\)|ansi_str::AnsiStr::ansi_strip\(&table\)),\s*(?:static_table!\(\s*)?(?<expected>(?:"(?:\\.|[^"\\])*"\s*)+),?\s*(?:\)\s*)?\);'
    let expectations = ($body | parse --regex $pattern | each {|entry| expected-lines $entry.expected })
    let count = if ($name | str starts-with 'hyperlinks') { 3 } else { 2 }
    if ($expectations | length) != $count {
      error make {msg: $'Expected ($count) original assertions in ($name), found ($expectations | length)'}
    }
    let action = if ($name | str starts-with 'wrapping_') {
      let colored = $name == 'wrapping_as_total_multiline_color'
      $"for index, words in [false, true] {
    let table = upstream_width_versions\(($colored))
      .with_\(@tabular.Alignment::left\())
      .with_\(@tabular.Width::wrap\(57).keep_words\(words))
      .to_string\()
    assert_eq\(table, expected[index])
    upstream_assert_width\(table, 57)
  }"
    } else if $name == 'truncating_as_total_multiline_color' {
      "let table = upstream_width_versions(true)
    .with_(@tabular.Alignment::left())
    .with_(@tabular.Width::truncate(57))
    .to_string()
  assert_eq(@papergrid.strip_ansi(table), expected[0])
  assert_eq(table, expected[1])
  assert_eq(@papergrid.get_text_width(table), 57)"
    } else {
      let color_first = $name in [hyperlinks_with_color hyperlinks_colored_truncate]
      let color_all = $name == 'hyperlinks_colored_truncate'
      let truncate = $name in [hyperlinks_truncate hyperlinks_colored_truncate]
      let width = if $name == 'hyperlinks_with_color' { 6 } else { 5 }
      let option = if $truncate { '.with_(@tabular.Width::truncate(20))' } else {
        '.with_(@tabular.Modify::new(@tabular.Segment::all()).with_(@tabular.Width::wrap(' + ($width | into string) + ').keep_words(true)).with_(@tabular.Alignment::left()))'
      }
      $"for index, text in upstream_width_links\(($color_first), ($color_all)) {
    let table = @tabular.Table::from_rows\([[\"name\", \"is_hyperlink\"], [text, \"true\"]])
      ($option).to_string\()
    assert_eq\(table, expected[index])
  }"
    }
    $"///|\n// Upstream: tabled/tests/settings/width_test.rs::($name)
test \"upstream width ($name)\" {
  let expected = [($expectations | str join ', ')]
  ($action)
}\n"
  } | str join (char nl)
}

def main [upstream: path, --output: path] {
  let project = ($env.CURRENT_FILE | path dirname | path dirname)
  let output = if $output == null { $project | path join upstream_width_test.mbt } else { $output | path expand }
  let relative = 'tabled/tests/settings/width_test.rs'
  let source = (open --raw ($upstream | path expand | path join $relative))
  let clean = ($source
    | str replace --all --regex '(?m)^\s*//[^\n]*' ''
    | str replace --all --regex '(?s)r#"(.*?)"#' {|content| $content | to json --raw })
  let pattern = '(?s)^\s*(?<name>\w+),\s*(?<expression>.*?)\s*,\s*(?<expected>(?:"(?:\\.|[^"\\])*"\s*)+)\s*\);'
  let chunks = ($clean | split row 'test_table!(' | skip 1)
  let cases = ($chunks | each {|chunk|
    let parsed = ($chunk | parse --regex $pattern)
    if ($parsed | length) != 1 { error make {msg: $'Cannot extract width case: ($chunk | str substring 0..100)'} }
    $parsed.0
  })
  let body = ($cases | each {|case|
    let expression = (width-expression $case.expression)
    let is_block = $expression | str ends-with '}'
    let returns_string = ($expression | str trim --right --char '}' | str trim | str ends-with '.to_string()') or ($expression | str trim --right --char '}' | str trim | str ends-with 'table')
    let actual = if $is_block and not $returns_string { '(' + $expression + ').to_string()' } else if $is_block or $returns_string { $expression } else { $expression + '.to_string()' }
    let expected = (expected-lines $case.expected)
    $"///|\n// Upstream: ($relative)::($case.name)
test \"upstream width ($case.name)\" {
  let actual = ($actual)
  assert_eq\(actual, ($expected))
}\n"
  } | str join (char nl))
  let marker = '// Generated by scripts/import-width-tests.nu.'
  if ($output | path exists) and not (open --raw $output | str starts-with $marker) {
    error make {msg: $'Refusing to overwrite a file not owned by this generator: ($output)'}
  }
  ($marker + "\n\n" + $body + (derived-tests $clean)) | save --force $output
  print $'width: ($cases | length) test_table cases and 7 original functions preserved'
}
