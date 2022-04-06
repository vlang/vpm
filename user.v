module main

struct User {
	id int
mut:
	name      string
	random_id string
}

fn (app App) retrieve_user(user_id int, random_id string) ?User {
	user := sql app.db {
		select from User where id == user_id && random_id == random_id limit 1
	}
	return user
}
