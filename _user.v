module main

struct User {
mut:
	name string
}

fn (app App) retrieve_user(user_id int, random_id string) ?User {
	users, _ := app.db.exec('select name from users where id=$user_id and random_id=$random_id')
	println('!!!ret user ($user_id, "$random_id") len = $users.len')
	if users.len == 0 {
		return error('no such user "$user_id" r="$random_id"')
	}
	return User{
		name: users[0].vals[0]
	}
}
