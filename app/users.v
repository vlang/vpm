module app

import nedpals.vex.ctx

fn get_user(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	user := app.services.users.get_by_username(req.params['username']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(user, 200)
}

fn admin_create_user_ban(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	if !authorized(app.user) {
		res.send_status(401)
		return
	}

	if !app.user.is_admin {
		res.send_status(403)
		return
	}

	user := app.services.users.get_by_username(req.params['username']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	app.services.users.set_blocked(user.id, true) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_status(200)
}

fn admin_delete_user_ban(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	if !authorized(app.user) {
		res.send_status(401)
		return
	}

	if !app.user.is_admin {
		res.send_status(403)
		return
	}

	user := app.services.users.get_by_username(req.params['username']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	app.services.users.set_blocked(user.id, false) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_status(200)
}
