#!/usr/bin/env nu
use std/assert
use upstream-literals.nu [decode-rust-string expected-lines moon-string]

assert equal (decode-rust-string '"\u{1b}[41m"') ((char -u '1b') + '[41m')
assert equal (decode-rust-string '"\\u{1b}"') '\u{1b}'
assert equal (decode-rust-string '"\u{1F600}"') '😀'
assert equal (decode-rust-string '"a\t\r\n\0\x1b"') ("a\t\r\n" + (char -u '0') + (char -u '1b'))
assert equal (decode-rust-string '"a\\\"b"') 'a\"b'
assert equal (decode-rust-string "\"a\nb\"") "a\nb"
assert equal (expected-lines '"a " "b"') (moon-string "a \nb")
assert equal (expected-lines 'r#"a"b"# r#" c "#') (moon-string "a\"b\n c ")
assert error { decode-rust-string '"\u{invalid}"' }
print 'Upstream literal decoding checks passed'
