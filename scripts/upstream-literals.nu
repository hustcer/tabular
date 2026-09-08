# String conversion shared by upstream test importers (Nushell 0.115+).

# Decode the ordinary Rust string literals used in the selected test suites.
# Tokenize escapes so a literal backslash followed by `u` stays literal.
export def decode-rust-string [literal: string]: nothing -> string {
  $literal
  | str replace --all --regex '\\\r?\n\s*' ''
  | str replace --all --regex '\\(?:u\{[0-9a-fA-F_]+\}|x[0-9a-fA-F]{2}|0|.)' {
      let escape = $in
      if ($escape | str starts-with '\u{') or ($escape | str starts-with '\x') or $escape == '\0' {
        let code = if $escape == '\0' { '0' } else {
          $escape | str replace --regex '^\\(?:u\{|x)' '' | str trim --right --char '}' | str replace --all '_' ''
        }
        char -u $code | to json --raw | str substring 1..-2
      } else { $escape }
    }
  | str replace --all (char nl) '\n'
  | from json
}

export def moon-string [text: string]: nothing -> string {
  if $text == '' or $text =~ '[\x00-\x09\x0b-\x1f]' {
    $text | to json --raw
  } else if $text =~ '(?m) +$' {
    # Keep significant trailing spaces inside quoted strings rather than at EOL.
    "[\n" + ($text | split row (char nl) | each {|line| '    ' + ($line | to json --raw) + ',' } | str join (char nl)) + "\n  ]" + '.join("\n")'
  } else {
    "(\n" + ($text | split row (char nl) | each {|line| '    #|' + $line } | str join (char nl)) + "\n  )"
  }
}

export def expected-lines [source: string]: nothing -> string {
  let parts = if ($source | str trim | str starts-with 'r#"') {
    $source | parse --regex '(?s)r#"(?<text>.*?)"#' | get text
  } else {
    $source | parse --regex '(?s)(?<text>"(?:\\.|[^"\\])*")' | get text | each {|text| decode-rust-string $text }
  }
  if ($parts | is-empty) { error make {msg: 'No expected string literals found'} }
  moon-string ($parts | str join (char nl))
}
