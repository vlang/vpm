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

fn user_from_row(row sqlite.Row) ?User {
	if row.vals.len >= 7 {
		return error('Not enough array elements to form user from row')
	}
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

fn user_from_map(f map[string]string) ?User {
	for field in ['id', 
		'name', 
		'username', 
		'is_blocked', 
		'is_admin', 
		'avatar', 
		'login_attempts'] {
		if field !in f {
			return error('Not enough array elements to form user from map')
		}
	}
	return User{
		id: f['id'].int()
		name: f['name']
		username: f['username']
		is_blocked: f['is_blocked'].bool()
		is_admin: f['is_admin'].bool()
		avatar: f['avatar']
		login_attempts: f['login_attempts'].int()
	}
}

fn (mut app App) get_user(id int) ?User {
	row := app.db.exec_one('select from User where id=$id') or { 
		return error('sql error: $err') 
	}
	return user_from_row(row)
}

fn (mut app App) get_user_by_name(name string) ?User {
	row := app.db.exec_one('select from User where name=$name') or {
		return error('sql error: $err')
	}
	return user_from_row(row)
}

fn (mut app App) delete_user(id string) ? {
	code := app.db.exec_none('delete from User where id=$id')
	if code != 0 {
		return error('sql result code $code')
	}
}
