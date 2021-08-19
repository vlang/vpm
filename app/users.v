module app

import json
import vweb

[get]
['/api/user/:username']
fn (mut app App) get_user(username string) vweb.Result {
	user := app.services.users.get_by_username(username) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(user))
}

[post]
['/api/bans/:username']
fn (mut app App) admin_create_user_ban(username string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	user := app.services.users.get_by_username(username) or {
		return wrap_service_error(mut app, err)
	}

	app.services.users.set_blocked(user.id, true) or {
		return wrap_service_error(mut app, err)
	}

	return app.ok('')
}

[delete]
['/api/bans/:username']
fn (mut app App) admin_delete_user_ban(username string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	user := app.services.users.get_by_username(username) or {
		return wrap_service_error(mut app, err)
	}

	app.services.users.set_blocked(user.id, false) or {
		return wrap_service_error(mut app, err)
	}

	return app.ok('')
}
