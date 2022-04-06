module main

struct User {
	id int
mut:
	name      string
	random_id string
}

fn (app App) retrieve_user(user_id int, random_id string) ?User {
	/*
	user := sql app.db {
		select from User where id == user_id && random_id == random_id limit 1
	}
	return user
	*/
	users := app.db.exec_param('select name from "User" where id=$user_id and random_id=$1',
		random_id) or { return err }
	println('!!!ret user ($user_id, "$random_id") len = $users.len')
	if users.len == 0 {
		return error('no such user "$user_id" r="$random_id"')
	}
	return User{
		name: users[0].vals[0]
	}
}
