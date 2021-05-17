module main

import models

fn (mut app App) get_user(query string) ?models.User {
	mut not_found := false
	mut error := error('')

	mut usr := app.users.get_user(query.int()) or { // get user by id
		not_found = true
		error = err
		models.User{}
	}
	if not_found == false {
		return usr
	}

	not_found = false

	usrs = app.users.get_users_by_name(query) or {
		not_found = true
		error = err
		models.User{}
	}
	if not_found == false {
		return usrs[0]
	}

	return err
}