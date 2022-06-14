module app

import vweb

['/api/user/:login'; get]
fn (mut app App) api_user(login string) vweb.Result {
	user := rlock app.services{ app.services.users.get_by_login(login) or { return wrap_service_error(mut app, err) }}

	return app.json(user)
}

['/api/bans/:login'; post]
fn (mut app App) api_admin_create_user_ban(login string) vweb.Result {
	// if !app.authorized() {
	// 	return send_status(mut app, .unauthorized)
	// }

	// if !app.user.is_admin {
	// 	return send_status(mut app, .forbidden)
	// }

	lock app.services {
		user := app.services.users.get_by_login(login) or { return wrap_service_error(mut app, err) }
		app.services.users.set_blocked(user.id, true) or { return wrap_service_error(mut app, err) }
	}

	return send_status(mut app, .ok)
}

['/api/bans/:login'; delete]
fn (mut app App) api_admin_delete_user_ban(login string) vweb.Result {
	// if !app.authorized() {
	// 	return send_status(mut app, .unauthorized)
	// }

	// if !app.user.is_admin {
	// 	return send_status(mut app, .forbidden)
	// }

	lock app.services {
		user := app.services.users.get_by_login(login) or { return wrap_service_error(mut app, err) }
		app.services.users.set_blocked(user.id, false) or { return wrap_service_error(mut app, err) }
	}

	return send_status(mut app, .ok)
}
