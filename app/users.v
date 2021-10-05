module app

import json
import vweb

['/api/user/:login'; get]
fn (mut app App) api_user(login string) vweb.Result {
	user := app.services.users.get_by_login(login) or { return wrap_service_error(mut app, err) }

	return app.json(json.encode(user))
}

['/api/bans/:login'; post]
fn (mut app App) api_admin_create_user_ban(login string) vweb.Result {
	if !app.authorized() {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	user := app.services.users.get_by_login(login) or { return wrap_service_error(mut app, err) }

	app.services.users.set_blocked(user.id, true) or { return wrap_service_error(mut app, err) }

	return app.ok('')
}

['/api/bans/:login'; delete]
fn (mut app App) api_admin_delete_user_ban(login string) vweb.Result {
	if !app.authorized() {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	user := app.services.users.get_by_login(login) or { return wrap_service_error(mut app, err) }

	app.services.users.set_blocked(user.id, false) or { return wrap_service_error(mut app, err) }

	return app.ok('')
}
