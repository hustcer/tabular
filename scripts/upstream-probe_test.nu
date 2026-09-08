#!/usr/bin/env nu
use std/assert
use upstream-probe.nu build-upstream-probe

const source = path self reference/dimension_probe.rs

# Integration check against the pinned upstream checkout; requires Cargo/rustc.
def main [upstream: path] {
  let rust = (^rustc -vV | complete)
  assert equal $rust.exit_code 0
  let host = ($rust.stdout | lines | parse 'host: {triple}' | get triple | first)
  let scratch = (mktemp --directory)
  try {
    for explicit_target in [false true] {
      let case_dir = ($scratch | path join $'probe ($explicit_target)')
      let environment = {CARGO_TARGET_DIR: ($scratch | path join 'external target')}
      let environment = if $explicit_target {
        $environment | insert CARGO_BUILD_TARGET $host
      } else {
        $environment
      }
      let executable = (with-env $environment {
        build-upstream-probe $upstream $source $case_dir
      })
      assert ($executable | path exists)
      let relative = ($executable | path relative-to ($case_dir | path join target))
      assert (not ($relative | str starts-with '..'))
      if $explicit_target {
        assert equal ($relative | path split | first) $host
      }
      let result = (^$executable priority none '0' '2' | complete)
      assert equal $result.exit_code 0
      let choices = ($result.stdout | lines | into int)
      assert equal ($choices | length) 30
      assert equal ($choices | first 2) [0 0]
      assert equal ($choices | skip 2 | uniq) [-1]
    }
  } finally {
    rm --recursive $scratch
  }
  assert (not ($scratch | path exists))
  print 'Reference probe checks passed with custom output directories and explicit host target'
}
