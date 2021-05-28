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
		check_one(err) ?
	}
	return row.vals[0]
}

fn exec_array(db sqlite.DB, query string) ?[]int {
	dump(query)
	rows, code := db.exec(query)
	check_sql_code(code) ?
	return r2array(rows)
}

fn check_one(err IError) ? {
	if err.msg == "No rows" {
		return IError(&NotFoundError{code:err.code})
	} else {
		return IError(&SQLError{msg:err.msg, code:err.code})
	}
}

fn check_sql_code(code int) ? {
	if code == 101 {
		return
	}

	return IError(&SQLError{msg: unsafe { cstring_to_vstring(&char(C.sqlite3_errstr(code))) }, code: code})
}

// Converts sqlite rows with one element into array
fn r2array(rows []sqlite.Row) []int {
	mut arr := []int{cap: rows.len}
	for row in rows {
		arr << row.vals[0].int()
	}
	return arr
}
