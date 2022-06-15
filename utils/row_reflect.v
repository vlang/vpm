module utils

import time

pub fn from_row<T>(mut dest T, row Row, selected_fields ...string) ? {
	mut iter := row_iterator(row)
	mut item := ''

	$for field in T.fields {
		mut row_field := field.name

		for attr in field.attrs {
			if attr.starts_with('row: ') {
				row_field = attr.trim_string_left('json: ')
			}
		}

		if selected_fields.len == 0 || row_field in selected_fields {
			item = iter.next()?

			$if field.typ is string {
				dest.$(field.name) = item.str()
			} $else $if field.typ is i64 {
				dest.$(field.name) = item.i64()
			} $else $if field.typ is int {
				dest.$(field.name) = item.int()
			} $else $if field.typ is bool {
				dest.$(field.name) = item.bool()
			} $else $if field.typ is time.Time {
				value := item.str()
				dest.$(field.name) = time.parse(value) or {
					time.parse_iso8601(value) or {
						println('Unable to parse time for `$field.name` field, value was `$item`')
						time.unix(0)
					}
				}
			}
		}
	}
}
