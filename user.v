module main

import sqlite

struct User {
	id         int
	name       string
	username   string
	is_blocked bool
	is_admin   bool
mut:
	avatar         string
	b_avatar       bool   [skip]
	login_attempts int
}

fn user_from_row(row sqlite.Row) User {
	return User{
		id: row.vals[0].int()
		name: row.vals[1]
		username: row.vals[2]
		is_blocked: row.vals[3].bool()
		is_admin: row.vals[4].bool()
		avatar: row.vals[5]
		login_attempts: row.vals[6].int()
	}
}

fn (mut app App) get_user(id int) ?User {
	row := app.db.exec_one('select from User where id=$id') or { return error('sql error: $err') }
	return user_from_row(row)
}

fn (mut app App) get_user_by_name(name string) ?User {
	row := app.db.exec_one('select from User where name=$name') or {
		return error('sql error: $err')
	}
	return user_from_row(row)
}
