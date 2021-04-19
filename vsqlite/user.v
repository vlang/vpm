module vsqlite

import sqlite

// TODO: Think more, THINK! This down here is shit!
pub interface UserService {
	create_user(user User) ?User
	get_user(id int) ?User
	get_users_by_name(like string) ?[]User
	update_user(user User) ?User
	delete_user(id int) ?User
}

pub struct UserService {
	db sqlite.DB
}

pub fn new_user_service(db sqlite.DB) ?UserService {
	db.exec_none("PRAGMA foreign_keys = ON;") or {
		return error('sql error: $err')
	}

	create_table(db, 'user', [
		'id INT NOT NULL PRIMARY KEY',
		'username TEXT NOT NULL UNIQUE',
		'avatar_url TEXT NOT NULL',

		'is_blocked BOOLEAN DEFAULT 0 CHECK (is_blocked IN (0, 1))',
		'is_admin BOOLEAN DEFAULT 0 CHECK (is_admin IN (0, 1))',
		'login_attempts INT DEFAULT 0',
	]) ?

	return UserService{
		db: db
	}
}

pub fn (s UserService) create_user(user User) ?User {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	s.exec_none("INSERT INTO user ("+
		"username, avatar_url, is_blocked, is_admin, login_attempts" + 
		") VALUES " + user_to_row(user) + ";"
	) or {
		return error('sql error: $err')
	}
	row := s.db_exec_one('SELECT * FROM user WHERE id = $package.id;') or {
		return error('sql error: $err')
	}
	return user_from_row(row)
}

pub fn (s UserService) get_user(id int) ?User {
	// Doing it by hands because we need control over errors
	row := s.db.exec_one('SELECT * FROM user WHERE id = $id;') or {
		return error('sql error: $err')
	}
	return user_from_row(row)
}

pub fn (s UserService) get_users_by_name(like string) ?[]User {
	// Doing it by hands because we need control over errors
	row := s.db.exec_one("SELECT * FROM user WHERE id LIKE '%$like%';") or {
		return error('sql error: $err')
	}
	return user_from_row(row)
}

pub fn (s UserService) update_user(user User) ?User {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	s.db.exec_none("UPDATE user SET " +
		"username = '$user.username', " +
		"avatar_url = '$user.avatar_url', " +
		"is_blocked = '${user.is_blocked.str()}', " +
		"is_admin = '${user.is_admin.str()}', " +
		"login_attempts = $user.login_attempts " +
		"WHERE id = $user.id;"
	) or {
		return error('sql error: $err')
	}
	row := s.db_exec_one('SELECT * FROM user WHERE id = $package.id;') or {
		return error('sql error: $err')
	}
	return user_from_row(row)
}

pub fn (s UserService) delete_user(id int) ?User {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	usr := s.get_user(id) ?
	s.db.exec_none('DELETE FROM user WHERE id = $id;') or {
		return error('sql error: $err')
	}
	return usr
}