module repository

import sqlite
import models

pub struct UsersRepo {
	db sqlite.DB
}

pub fn new_users_repo(db sqlite.DB) UsersRepo {
	return UsersRepo{
		db: db
	}
}

pub fn (r UsersRepo) create(user models.User) ?int {
	exec(r.db, 'INSERT INTO $users_table ' +
		'(name, username, avatar_url, is_blocked, is_admin, login_attempts) ' + 'VALUES' + "('" +
		[user.name, user.username, user.avatar_url].join("', '") + "', " + user.is_blocked.str() +
		', ' + user.is_admin.str() + ', ' + user.login_attempts.str() + "');") ?

	id := exec_field(r.db, 'SELECT id FROM $users_table ' + "WHERE username = '$user.username';") ?
	return id.int()
}

pub fn (r UsersRepo) get_by_id(id int) ?models.User {
	query := 'SELECT name, username, avatar_url, ' + 'is_blocked, is_admin, login_attempts ' +
		'FROM $users_table WHERE id = $id;'
	row := r.db.exec_one(query) ?

	mut cursor := new_cursor()
	pkg := models.User{
		id: id
		name: row.vals[cursor.next()]
		username: row.vals[cursor.next()]
		avatar_url: row.vals[cursor.next()]
		is_blocked: row.vals[cursor.next()].bool()
		is_admin: row.vals[cursor.next()].bool()
		login_attempts: row.vals[cursor.next()].int()
	}

	return pkg
}

pub fn (r UsersRepo) get_by_username(username string) ?models.User {
	query := 'SELECT id, name, avatar_url, ' + 'is_blocked, is_admin, login_attempts ' +
		"FROM $users_table WHERE username = '$username';"
	row := r.db.exec_one(query) ?

	mut cursor := new_cursor()
	id := row.vals[cursor.next()].int()
	pkg := models.User{
		id: id
		name: row.vals[cursor.next()]
		username: username
		avatar_url: row.vals[cursor.next()]
		is_blocked: row.vals[cursor.next()].bool()
		is_admin: row.vals[cursor.next()].bool()
		login_attempts: row.vals[cursor.next()].int()
	}

	return pkg
}

pub fn (r UsersRepo) set_name(id int, name string) ? {
	exec(r.db, "UPDATE $users_table SET name = '$name' WHERE id = $id;") ?
}

pub fn (r UsersRepo) set_username(id int, username string) ? {
	exec(r.db, "UPDATE $users_table SET username = '$username' WHERE id = $id;") ?
}

pub fn (r UsersRepo) set_avatar_url(id int, avatar_url string) ? {
	exec(r.db, "UPDATE $users_table SET avatar_url = '$avatar_url' WHERE id = $id;") ?
}
