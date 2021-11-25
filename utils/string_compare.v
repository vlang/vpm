module utils

// Constant time string comparison.
// First arg should be provided by the user/attacker/outside,
// second arg is internal, known string that’s being checked for a match
[direct_array_access]
pub fn secure_compare(outside string, internal string) bool {
	mut m := int(0)
	mut i := usize(0)
	mut j := usize(0)
	mut k := usize(0)

	for {
		m |= outside[i] ^ internal[j]

		if outside[i] == `\0` {
			break
		}

		i++

		if internal[j] != `\0` {
			j++
		}

		if internal[j] == `\0` {
			k++
		}
	}

	return m == 0
}
