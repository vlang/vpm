module utils

// Row interface for Sqlite, Postgres rows
pub interface Row {
	vals []string
}

// Help iterating over database rows (sql-like drivers)
pub struct RowIterator {
	vals []string
mut:
	idx usize
}

// Create new `row` iterator
pub fn row_iterator(row Row) RowIterator {
	return RowIterator{
		vals: row.vals
	}
}

// Get next value of row
pub fn (mut iter RowIterator) next() ?string {
	if iter.idx >= iter.vals.len {
		return error('out of bounds')
	}

	defer {
		iter.idx++
	}

	return iter.vals[iter.idx]
}
