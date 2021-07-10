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
	exec(r.db, 'INSERT INTO $users_table ' + '(username, avatar_url, github_id) ' + 'VALUES' +
		"('" + [user.username, user.avatar_url].join("', '") + "', $user.github_id);") ?

	id := exec_field(r.db, 'SELECT id FROM $users_table ' + "WHERE github_id = '$user.github_id';") ?
	return id.int()
}

pub fn (r UsersRepo) get_by_id(id int) ?models.User {
	query := 'SELECT github_id, name, username, avatar_url, ' +
		'is_blocked, is_admin, login_attempts ' + 'FROM $users_table WHERE id = $id;'
	row := r.db.exec_one(query) or { return error_one(err) }

	mut cursor := new_cursor()
	pkg := models.User{
		id: id
		github_id: row.vals[cursor.next()].int()
		name: row.vals[cursor.next()]
		username: row.vals[cursor.next()]
		avatar_url: row.vals[cursor.next()]
		is_blocked: row.vals[cursor.next()].bool()
		is_admin: row.vals[cursor.next()].bool()
	}

	return pkg
}

pub fn (r UsersRepo) get_by_github_id(id int) ?models.User {
	query := 'SELECT id, name, username, avatar_url, is_blocked, is_admin ' +
		'FROM $users_table WHERE github_id = $id;'
	row := r.db.exec_one(query) or { return error_one(err) }

	mut cursor := new_cursor()
	pkg := models.User{
		id: row.vals[cursor.next()].int()
		github_id: id
		name: row.vals[cursor.next()]
		username: row.vals[cursor.next()]
		avatar_url: row.vals[cursor.next()]
		is_blocked: row.vals[cursor.next()].bool()
		is_admin: row.vals[cursor.next()].bool()
	}

	return pkg
}

pub fn (r UsersRepo) get_by_username(username string) ?models.User {
	query := 'SELECT id, github_id, name, avatar_url, ' + 'is_blocked, is_admin, login_attempts ' +
		"FROM $users_table WHERE username = '$username';"
	row := r.db.exec_one(query) or { return error_one(err) }

	mut cursor := new_cursor()
	pkg := models.User{
		id: row.vals[cursor.next()].int()
		github_id: row.vals[cursor.next()].int()
		name: row.vals[cursor.next()]
		username: username
		avatar_url: row.vals[cursor.next()]
		is_blocked: row.vals[cursor.next()].bool()
		is_admin: row.vals[cursor.next()].bool()
	}

	return pkg
}

pub fn (r UsersRepo) update(user models.User) ? {
	if user.name != '' {
		exec(r.db, "UPDATE $users_table SET name = '$user.name' WHERE id = $user.id;") ?
	}

	if user.username != '' {
		exec(r.db, "UPDATE $users_table SET username = '$user.username' WHERE id = $user.id;") ?
	}

	if user.avatar_url != '' {
		exec(r.db, "UPDATE $users_table SET avatar_url = '$user.avatar_url' WHERE id = $user.id;") ?
	}
}

pub fn (r UsersRepo) set_blocked(id int, is_blocked bool) ? {
	exec(r.db, 'UPDATE $users_table SET is_blocked = $is_blocked WHERE id = $id;') ?
}

pub fn (r UsersRepo) set_admin(id int, is_admin bool) ? {
	exec(r.db, 'UPDATE $users_table SET is_admin = $is_admin WHERE id = $id;') ?
}
