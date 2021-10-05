module repository

import pg
import dto
import models

pub struct Users {
	db pg.DB
}

pub fn new_users(db pg.DB) Users {
	return Users{
		db: db
	}
}

pub fn (repo Users) create(user dto.User) ?models.User {
	row := repo.db.exec_one('INSERT INTO $models.users_table ' +
		'(gh_id, gh_login, gh_avatar, name, gh_access_token) ' + 'VALUES' + "($user.gh_id, '" +
		[user.gh_login, user.gh_avatar, user.name, user.gh_access_token].join("', '") +
		"') RETURNING $models.user_fields;") ?
	return models.row2user(row)
}

pub fn (repo Users) get_by_id(id int) ?models.User {
	row := repo.db.exec_one('SELECT $models.user_fields FROM $models.users_table WHERE id = $id;') ?
	return models.row2user(row)
}

pub fn (repo Users) get_by_github_id(id int) ?models.User {
	row := repo.db.exec_one('SELECT $models.user_fields FROM $models.users_table WHERE gh_id = $id;') ?
	return models.row2user(row)
}

pub fn (repo Users) get_by_login(login string) ?models.User {
	row := repo.db.exec_one("SELECT $models.user_fields FROM $models.users_table WHERE gh_login = '$login';") ?
	return models.row2user(row)
}

// Please fetch user before updating
pub fn (repo Users) update(user dto.User) ?models.User {
	// if user.name != '' && user.username != '' && user.avatar_url != '' {
	// 	row := r.db.exec_one("UPDATE $users_table SET name = '$user.name', username = '$user.username', avatar_url = '$user.avatar_url' WHERE id = $user.id RETURNING $user_fields;") ?
	// 	return models.row2user(row)
	// }
	return error('Stop right there you criminal scum')
}

pub fn (repo Users) set_blocked(id int, is_blocked bool) ?models.User {
	row := repo.db.exec_one('UPDATE $models.users_table SET is_blocked = $is_blocked WHERE id = $id RETURNING $models.user_fields;') ?
	return models.row2user(row)
}

pub fn (repo Users) set_admin(id int, is_admin bool) ?models.User {
	row := repo.db.exec_one('UPDATE $models.users_table SET is_admin = $is_admin WHERE id = $id RETURNING $models.user_fields;') ?
	return models.row2user(row)
}
