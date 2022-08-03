module sql

// Help iterating over database rows (sql-like drivers)
struct Iterator {
	vals []string
mut:
	idx usize
}

// Create new `row` iterator
fn iterator(vals []string) Iterator {
	return Iterator{
		vals: vals
	}
}

// Get next value of row
pub fn (mut iter Iterator) next() ?string {
	if iter.idx >= iter.vals.len {
		return error('out of bounds')
	}

	defer {
		iter.idx++
	}

	return iter.vals[iter.idx]
}
