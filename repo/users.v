module repo

import orm
import entity { User }

pub struct UsersRepo {
mut:
	db orm.Connection @[required]
}

pub fn migrate_users(db orm.Connection) ! {
	sql db {
		create table User
	}!
	mut db_mut := db
	db_mut.execute('ALTER TABLE "user" ADD COLUMN IF NOT EXISTS github_token TEXT NOT NULL DEFAULT \'\'')!
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

fn (u UsersRepo) get_by_id(id int) ?User {
	users := sql u.db {
		select from User where id == id
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

pub fn (u UsersRepo) update_github_token(user_id int, token string) ! {
	sql u.db {
		update User set github_token = token where id == user_id
	}!
}
