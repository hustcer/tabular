# Translate pinned upstream spellings into the public MoonBit API.
# Tokenize literals before editing calls so expected strings and nested commas
# remain untouched. This adapter is for generated expressions, not Rust source.

def call-arguments [tokens: list<string>, start: int]: nothing -> record {
  mut depth = 0
  mut args = []
  mut current = []
  for index in $start..<($tokens | length) {
    let token = $tokens | get $index
    if $token == ')' and $depth == 0 {
      let arg = ($current | str join '' | str trim)
      if $arg != '' { $args = ($args | append $arg) }
      return {args: $args, end: $index}
    }
    if $token == ',' and $depth == 0 {
      $args = ($args | append ($current | str join '' | str trim))
      $current = []
    } else {
      if $token in ['(' '[' '{'] { $depth += 1 }
      if $token in [')' ']' '}'] { $depth -= 1 }
      $current = ($current | append $token)
    }
  }
  return (error make {msg: 'Unbalanced generated API call'})
}

def labeled-call [name: string, args: list<string>, labels: list<string>]: nothing -> string {
  if ($args | length) != ($labels | length) { error make {msg: $'Unexpected argument count for ($name)'} }
  let values = ($args | enumerate | each {|arg|
    let label = $labels | get $arg.index
    if $label == '' or $arg.item =~ '^\w+\s*[=~]' { $arg.item } else { $label + '=' + $arg.item }
  } | str join ', ')
  $name + '(' + $values + ')'
}

# Convert an expression after its Rust syntax and package aliases are translated.
export def modernize-api []: string -> string {
  let code = $in
  let tokens = ($code | parse --regex r#'(?s)(?<token>//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[A-Za-z_]\w*(?:::[A-Za-z_]\w*)?|\s+|.)'# | get token)
  let names = {
    'Dup::new': 'Duplicate::new'
    'Justification::new': 'AlignmentFill::new'
    'Justification::colored': 'AlignmentFill::colored'
    'Justification::default': 'AlignmentFill::default'
    'Charset::new': 'TextCleanup::new'
    'Charset::default': 'TextCleanup::default'
    'Charset::charset_clean': 'TextCleanup::clean_text'
    'Justify::new': 'UniformWidth::new'
    'Justify::min': 'UniformWidth::min'
    'Justify::max': 'UniformWidth::max'
    'Width::justify': 'Width::uniform'
    'PriorityNone::new': 'PriorityRoundRobin::new'
    'PriorityNone::default': 'PriorityRoundRobin::default'
    'PriorityLeft::new': 'PriorityFirst::new'
    'PriorityLeft::default': 'PriorityFirst::default'
    'PriorityRight::new': 'PriorityLast::new'
    'PriorityRight::default': 'PriorityLast::default'
    'PriorityMin::left': 'PriorityMin::prefer_last'
    'PriorityMin::right': 'PriorityMin::prefer_first'
    'PriorityMax::left': 'PriorityMax::prefer_first'
    'PriorityMax::right': 'PriorityMax::prefer_last'
    'Reverse::columns': 'Reverse::cols'
    'Span::column': 'Span::col'
    'Entity::Column': 'Entity::Col'
    'Color::parse': 'Color::parse_or_abort'
    'Color::try_from': 'Color::try_parse'
    'Color::rgb_fg': 'Color::fg_rgb'
    'Color::rgb_bg': 'Color::bg_rgb'
    'ANSIBuf::try_from': 'ANSIBuf::try_parse'
    'get_dimension': 'dimension_snapshot'
    'get_dimension_mut': 'dimension_cache'
    'suffix_try_color': 'inherit_suffix_style'
    'tab_size': 'expand_tabs'
    'bitor': 'combine'
    'trim_ansi': 'trim_ansi_whitespace'
  }
  let call_names = ['Duplicate::new' 'Formatting::new' 'Margin::new' 'MarginColor::new' 'PaddingColor::new' 'Sides::new' 'Wrap::wrap' 'Modify::list' 'Padding::expand' 'fill' 'limit' 'rotate']
  mut output = []
  mut index = 0
  while $index < ($tokens | length) {
    let original = $tokens | get $index
    mut token = ($names | get -o $original | default $original)
    if $token == 'clean' and ($output | str join '') =~ 'TextCleanup::new\(\)\s*\.\s*$' {
      $token = 'remove_control_chars'
    }
    mut open = $index + 1
    while $open < ($tokens | length) and ($tokens | get $open) =~ '^\s+$' { $open += 1 }
    if $token in $call_names and ($tokens | get -o $open) == '(' {
      let call = (call-arguments $tokens ($open + 1))
      let args = ($call.args | each { modernize-api })
      let rendered = match $token {
        'Duplicate::new' => {
          if ($args | any { $in =~ '^(source|destination)\s*=' }) {
            'Duplicate::new(' + ($args | str join ', ') + ')'
          } else { labeled-call $token [$args.1 $args.0] [source destination] }
        }
        'Formatting::new' => { labeled-call $token $args [trim_horizontal trim_vertical align_lines] }
        'Margin::new' | 'MarginColor::new' | 'PaddingColor::new' | 'Sides::new' | 'fill' => {
          labeled-call $token $args [left right top bottom]
        }
        'Wrap::wrap' => { labeled-call $token $args ['' '' keep_words] }
        'Modify::list' => { 'Modify::new(' + $args.0 + ').with_(' + $args.1 + ')' }
        'Padding::expand' => {
          match $args.0 {
            'true' => 'PaddingExpand::Horizontal'
            'false' => 'PaddingExpand::Vertical'
            _ => { error make {msg: 'Expected literal padding expansion direction'} }
          }
        }
        'limit' => {
          let bound = ($args.0 | parse --regex '^(?:@\w+\.)?Offset::(?<kind>Start|End)\((?<value>.*)\)$')
          if ($bound | is-empty) { 'limit(' + ($args | str join ', ') + ')' } else {
            (if $bound.0.kind == 'Start' { 'take' } else { 'exclude_last' }) + '(' + $bound.0.value + ')'
          }
        }
        'rotate' => {
          let flip = ($args.0 | parse --regex '^(?<package>@\w+\.)?Rotate::(?:Top|Bottom)$')
          if ($flip | is-empty) { 'rotate(' + ($args | str join ', ') + ')' } else {
            'reverse(' + $flip.0.package + 'Reverse::rows(0))'
          }
        }
      }
      $output = ($output | append $rendered)
      $index = $call.end + 1
    } else {
      $output = ($output | append $token)
      $index += 1
    }
  }
  $output | str join ''
}
