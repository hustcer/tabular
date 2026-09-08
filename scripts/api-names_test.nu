#!/usr/bin/env nu
use std/assert
use api-names.nu modernize-api

assert equal ('@tabular.Dup::new(Cols::new(1, 4), Rows::one(0))' | modernize-api) '@tabular.Duplicate::new(source=Rows::one(0), destination=Cols::new(1, 4))'
assert equal ('Sides::new(f("中,文"), g(1, 2), [3, 4], { value: 5 })' | modernize-api) 'Sides::new(left=f("中,文"), right=g(1, 2), top=[3, 4], bottom={ value: 5 })'
assert equal ('"Dup::new(1, 2), Charset::new().clean()"' | modernize-api) '"Dup::new(1, 2), Charset::new().clean()"'
assert equal ("Margin::new(1, 2, 3, 4).fill('(', ',', ')', '\\'')" | modernize-api) "Margin::new(left=1, right=2, top=3, bottom=4).fill(left='(', right=',', top=')', bottom='\\'')"
assert equal ('x.rotate(@tabular.Rotate::Top).reverse(Reverse::rows(1).limit(Offset::Start(2)))' | modernize-api) 'x.reverse(@tabular.Reverse::rows(0)).reverse(Reverse::rows(1).take(2))'
assert equal ('Charset::new().clean().tab_size(4)' | modernize-api) 'TextCleanup::new().remove_control_chars().expand_tabs(4)'
assert equal ('Split::new().clean()' | modernize-api) 'Split::new().clean()'
assert equal ('PriorityMin::left() | PriorityMax::left()' | modernize-api) 'PriorityMin::prefer_last() | PriorityMax::prefer_first()'
assert equal ('PriorityLeft::default() | PriorityRight::default()' | modernize-api) 'PriorityFirst::default() | PriorityLast::default()'
assert equal ('Padding::expand(false)' | modernize-api) 'PaddingExpand::Vertical'
assert equal ('Formatting::new(true, false, true)' | modernize-api) 'Formatting::new(trim_horizontal=true, trim_vertical=false, align_lines=true)'
let labeled = 'Duplicate::new(source=Rows::one(0), destination=Rows::one(1))'
assert equal ($labeled | modernize-api | modernize-api) $labeled
assert error { 'Dup::new(1, (2)' | modernize-api }
print 'API name translation checks passed'
