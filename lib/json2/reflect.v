module json2

import time
import x.json2

pub fn to<T>(mut dest T, obj map[string]json2.Any) {
	$for field in T.fields {
		mut json_name := field.name

		for attr in field.attrs {
			if attr.starts_with('json:') {
				json_name = attr.all_after('json:').trim_space()
			}
		}

		if val := obj[json_name] {
			$if field.typ is string {
				dest.$(field.name) = val.str()
			} $else $if field.typ is i64 {
				dest.$(field.name) = val.i64()
			} $else $if field.typ is int {
				dest.$(field.name) = val.int()
			} $else $if field.typ is bool {
				dest.$(field.name) = val.bool()
			} $else $if field.typ is time.Time {
				value := val.str()
				dest.$(field.name) = time.parse(value) or {
					time.parse_iso8601(value) or {
						println('Unable to parse time for `$field.name` field, value was `$val`')
						time.unix(0)
					}
				}
			}
			// $else {
			// 	if field.is_mut {
			// 		// Pretending that all other fields have `from_json`
			// 		dest.$(field.name).from_json(val)
			// 	}
			// }
		}
	}
}
