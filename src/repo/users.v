module repo

import orm
import entity { User }

pub struct UsersRepo {
mut:
	db orm.Connection [required]
}

pub fn migrate_users(db orm.Connection) ! {
	sql db {
		create table User
	}!
}

pub fn users(db orm.Connection) UsersRepo {
	return UsersRepo{
		db: db
	}
}

fn (u UsersRepo) get(id int, random_id string) ?User {
	users := sql u.db {
		select from User where id == id && random_id == random_id
	} or { return none }
	if users.len == 0 {
		return none
	}
	return users[0]
}

fn (u UsersRepo) get_by_name(username string) ?User {
	users := sql u.db {
		select from User where username == username
	} or { return none }
	if users.len == 0 {
		return none
	}
	return users[0]
}
