module repo

import db.pg
import entity { User }

pub struct UsersRepo {
	db pg.DB [required]
}

pub fn new_users(db pg.DB) !&UsersRepo {
	sql db {
		create table User
	}!

	return &UsersRepo{
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
