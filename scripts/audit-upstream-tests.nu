#!/usr/bin/env nu
# List named upstream test candidates and explicit MoonBit source references.
# This is an inventory, not a Rust parser or a proof of behavioral coverage.
# It includes cfg-gated tests but excludes doctests and unnamed macro expansions.

def main [upstream: path, --output: path] {
  let project = ($env.CURRENT_FILE | path dirname | path dirname)
  let upstream = ($upstream | path expand)
  let rust_files = (^rg --files $upstream --glob '*.rs' | complete)
  if $rust_files.exit_code != 0 { error make {msg: $rust_files.stderr} }
  let moon_files = (^rg --files $project --glob '*_test.mbt' | complete)
  if $moon_files.exit_code != 0 { error make {msg: $moon_files.stderr} }
  let revision = (^git -C $upstream rev-parse HEAD | complete)
  if $revision.exit_code != 0 { error make {msg: $revision.stderr} }
  let references = ($moon_files.stdout | lines | each {|file|
    open --raw $file
    | parse --regex '(?m)^// Upstream: (?<source>[^\s]+\.rs)::(?<name>[\w:]+)'
    | each {|reference|
      {
        key: ($reference.source + '::' + ($reference.name | split row '::' | last))
        moonbit: ($file | path relative-to $project)
      }
    }
  } | flatten)
  let suites = ($rust_files.stdout | lines | sort | each {|file|
    let source = (open --raw $file)
    let relative = ($file | path relative-to $upstream)
    let macros = ($source
      | parse --regex '(?m)^\s*test_table!\(\s*(?<name>\w+)'
      | insert kind 'test_table')
    let functions = ($source
      | parse --regex '(?m)^\s*#\[(?<kind>test|quickcheck)\]\s*(?:#\[[^\n]*\]\s*)*(?:pub\s+)?(?:async\s+)?fn\s+(?<name>\w+)')
    let cases = ($macros | append $functions | each {|case|
      let key = $relative + '::' + $case.name
      let files = ($references | where key == $key | get moonbit | uniq)
      {
        name: $case.name
        kind: $case.kind
        moonbit_references: $files
        status: (if ($files | is-empty) { 'unmapped' } else { 'referenced' })
      }
    })
    if ($cases | is-empty) { null } else {
      {source: $relative, sha256: ($source | hash sha256), cases: $cases}
    }
  })
  let cases = ($suites | get cases | flatten)
  let result = {
    revision: ($revision.stdout | str trim)
    scope: 'Named test_table, test, and quickcheck candidates in workspace Rust sources; excludes doctests and unnamed macro expansions.'
    note: 'A source reference is a navigation aid, not evidence that all branches or expected outputs are equivalent. Existing tests without references remain unmapped.'
    source_files: ($suites | length)
    test_candidates: ($cases | length)
    referenced_candidates: ($cases | where status == referenced | length)
    suites: $suites
  }
  if $output == null {
    $result | reject suites | to json
  } else {
    $result | to json | save --force $output
    $result | reject suites | to json
  }
}
