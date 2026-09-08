///|
// Upstream: tabled/src/util/string.rs::test_srip_osc
test "upstream string test_srip_osc" {
  assert_eq(strip_osc("just a string here"), ("just a string here", None))
  assert_eq(strip_osc("/etc/rc.conf"), ("/etc/rc.conf", None))
  assert_eq(
    strip_osc(
      "https://gitlab.com/finestructure/swiftpackageindex-builder/-/pipelines/1054655982",
    ),
    (
      "https://gitlab.com/finestructure/swiftpackageindex-builder/-/pipelines/1054655982",
      None,
    ),
  )
  fn build_link_prefix_suffix(url : String) -> String {
    "\u001b]8;;" + url + "\u001b\\"
  }
  assert_eq(
    strip_osc(build_link_prefix_suffix("just a string here")),
    ("", Some("just a string here")),
  )
  assert_eq(
    strip_osc(build_link_prefix_suffix("/etc/rc.conf")),
    ("", Some("/etc/rc.conf")),
  )
  assert_eq(
    strip_osc(
      build_link_prefix_suffix(
        "https://gitlab.com/finestructure/swiftpackageindex-builder/-/pipelines/1054655982",
      ),
    ),
    (
      "",
      Some(
        "https://gitlab.com/finestructure/swiftpackageindex-builder/-/pipelines/1054655982",
      ),
    ),
  )
}
