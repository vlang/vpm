module main

fn is_valid_mod_name(s string) bool {
	if s.len > max_name_len || s.len < 2 {
		return false
	}
	for c in s {
		if !(c >= `A` && c <= `Z`) && !(c >= `a` && c <= `z`) && !(c >= `0` && c <= `9`) && c != `.` {
			return false
		}
	}
	return true
}
