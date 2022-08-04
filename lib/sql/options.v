module sql

import strings

pub enum Order {
	ascending
	descending
}

pub fn (o Order) str() string {
	return match o {
		.ascending { 'ASC' }
		.descending { 'DESC' }
	}
}

pub struct OrderBy {
	column string
	order  Order = Order.ascending
}

pub struct Options {
	order_by OrderBy
	offset   int
	limit    int     [required]
}

pub fn (opt Options) to_sql() ?string {
	mut b := strings.new_builder(64)

	if opt.order_by.column.len > 0 {
		b.write_string('order by $opt.order_by.column $opt.order_by.order ')
	}

	if opt.offset >= 0 {
		b.write_string('offset $opt.offset ')
	} else {
		return error('options: offset is negative')
	}

	if opt.limit >= 1 {
		b.write_string('limit $opt.limit ')
	} else {
		return error('options: limit is zero or negative')
	}

	return b.str()
}
