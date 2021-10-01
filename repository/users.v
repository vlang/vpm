module repository

import pg
import models

[heap]
pub struct Users {
	db pg.DB
}

pub fn new_users(db pg.DB) &Users {
	return &Users{
		db: db
	}
}

pub fn (r Users) create(user models.User) ?models.User {
	row := r.db.exec_one('INSERT INTO $users_table ' + '(login, avatar_url, github_id) ' + 'VALUES' +
		"('" + [user.login, user.avatar_url].join("', '") + "', $user.github_id) RETURNING $users_fields;") ?
	return row2user(row)
}

pub fn (r Users) get_by_id(id int) ?models.User {
	row := r.db.exec_one('SELECT $users_fields FROM $users_table WHERE id = $id;')?
	return row2user(row)
}

pub fn (r Users) get_by_github_id(id int) ?models.User {
	row := r.db.exec_one('SELECT $users_fields FROM $users_table WHERE github_id = $id;')?
	return row2user(row)
}

pub fn (r Users) get_by_username(username string) ?models.User {
	row := r.db.exec_one("SELECT $users_fields FROM $users_table WHERE username = '$username';")?
	return row2user(row)
}

// Please fetch user before updating
pub fn (r Users) update(user models.User) ?models.User {
	// if user.name != '' && user.username != '' && user.avatar_url != '' {
	// 	row := r.db.exec_one("UPDATE $users_table SET name = '$user.name', username = '$user.username', avatar_url = '$user.avatar_url' WHERE id = $user.id RETURNING $users_fields;") ?
	// 	return row2user(row)
	// }
	return error("why?")
}

pub fn (r Users) set_blocked(id int, is_blocked bool) ?models.User {
	row := r.db.exec_one('UPDATE $users_table SET is_blocked = $is_blocked WHERE id = $id RETURNING $users_fields;') ?
	return row2user(row)
}

pub fn (r Users) set_admin(id int, is_admin bool) ?models.User {
	row := r.db.exec_one('UPDATE $users_table SET is_admin = $is_admin WHERE id = $id RETURNING $users_fields;') ?
	return row2user(row)
}
