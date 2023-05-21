module repo

import db.pg
import entity { User }

interface Users {
	get(id int, random_id string) ?User
}

pub struct UsersRepo {
	db pg.DB
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
