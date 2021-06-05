module repository

import sqlite

fn C.sqlite3_errstr(int) &char

struct Cursor {
mut:
	cursor int
}

fn new_cursor() Cursor {
	return Cursor{}
}

fn (mut c Cursor) next() int {
	defer {
		c.cursor++
	}
	return c.cursor
}

fn exec(db sqlite.DB, query string) ? {
	code := db.exec_none(query)
	check_sql_code(code) ?
}

fn exec_field(db sqlite.DB, query string) ?string {
	row := db.exec_one(query) or {
		return error_one(err)
	}
	return row.vals[0]
}

fn exec_array(db sqlite.DB, query string) ?[]int {
	dump(query)
	rows, code := db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	return r2array(rows)
}

fn error_one(err IError) IError {
	if err.msg == "No rows" {
		return IError(&NotFoundError{code:err.code})
	}

	return do_error(err.code)
}

fn check_sql_code(code int) ? {
	if code == 101 {
		return
	}

	return do_error(code)
}

fn do_error(code int) IError {
	msg := unsafe { cstring_to_vstring(&char(C.sqlite3_errstr(code))) }

	if code in [275, 531, 787, 1043, 1299, 2835, 1555, 2579, 1811, 2067, 2323] {
		return IError(&ConstraintError{msg: msg, code: code})
	}

	return IError(&SQLError{msg: msg, code: code})
}

// Converts sqlite rows with one element into array
fn r2array(rows []sqlite.Row) []int {
	mut arr := []int{cap: rows.len}
	for row in rows {
		arr << row.vals[0].int()
	}
	return arr
}
