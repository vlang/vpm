module sql

import time

// Converts database row into T struct.
// Row values must match number of fields
pub fn from_row_to<T>(row []string, selected_fields []string) ?T {
	mut obj := T{}
	from_row<T>(mut obj, row, selected_fields)?
	return obj
}

// Unwraps database row into T struct.
// Row values must match number of fields
pub fn from_row<T>(mut dest T, row []string, selected_fields []string) ? {
	if row.len != selected_fields.len {
		return error('row values length != selected_fields length, $row.len and $selected_fields.len')
	}

	mut iter := iterator(row)
	mut item := ''

	$for field in T.fields {
		mut row_field := field.name

		for attr in field.attrs {
			if attr.starts_with('sql:') {
				row_field = attr.all_after('sql:').trim_space()
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

pub fn to_idents<T>() []string {
	mut idents := []string{}

	$for field in T.fields {
		mut obj_field := field.name

		for attr in field.attrs {
			if attr.starts_with('sql:') {
				obj_field = attr.all_after('sql:').trim_space()
			}
		}

		idents << obj_field
	}
	return idents
}

pub fn to_values<T>(obj T, idents []string) []string {
	mut values := []string{}

	$for field in T.fields {
		mut obj_field := field.name

		for attr in field.attrs {
			if attr.starts_with('sql:') {
				obj_field = attr.all_after('sql:').trim_space()
			}
		}

		if obj_field in idents {
			$if field.typ is string {
				values << "'" + obj.$(field.name) + "'"
			} $else $if field.typ is time.Time {
				values << "'" + obj.$(field.name).str() + "'"
			} $else {
				values << obj.$(field.name).str()
			}
		}
	}
	return values
}

pub fn to_set(idents []string, values []string) []string {
	mut set := []string{cap: idents.len}
	for i, _ in idents {
		set << idents[i] + ' = ' + values[i]
	}
	return set
}

pub fn value_to_sql<T>(value T) string {
}
