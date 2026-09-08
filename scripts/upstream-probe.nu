# Build reference probes from the audited source revision and locked dependencies.
const reference_dir = path self reference
const upstream_revision = '6f40434650aa0c8a27ecb243d42af605b4206b73'

export def build-upstream-probe [upstream: path, source: path, scratch: path]: nothing -> path {
  let root = ($upstream | path expand)
  let revision = (^git -C $root rev-parse HEAD | complete)
  if $revision.exit_code != 0 or ($revision.stdout | str trim) != $upstream_revision {
    error make {msg: $'Reference source must be tabled commit ($upstream_revision)'}
  }
  let status = (^git -C $root status --porcelain --untracked-files=normal -- tabled papergrid | complete)
  if $status.exit_code != 0 or ($status.stdout | str trim) != '' {
    error make {msg: 'Reference tabled/papergrid source must have no local changes'}
  }
  mkdir ($scratch | path join src)
  cp $source ($scratch | path join src/main.rs)
  cp ($reference_dir | path join Cargo.lock) ($scratch | path join Cargo.lock)
  {
    package: {name: 'tabular-upstream-probe', version: '0.0.0', edition: '2021'}
    dependencies: {
      papergrid: {path: ($root | path join papergrid), features: [ansi]}
      ansi-str: {version: '=0.9.0'}
      ansitok: {version: '=0.3.0'}
      tabled: {path: ($root | path join tabled), default-features: false, features: [std ansi]}
    }
    patch: {crates-io: {papergrid: {path: ($root | path join papergrid)}}}
  } | to toml | save ($scratch | path join Cargo.toml)
  let result = (^cargo build --locked --manifest-path ($scratch | path join Cargo.toml) | complete)
  if $result.exit_code != 0 { error make {msg: $result.stderr} }
  let executable = if $nu.os-info.name == 'windows' { 'tabular-upstream-probe.exe' } else { 'tabular-upstream-probe' }
  $scratch | path join target/debug $executable
}
