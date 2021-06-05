module app

import nedpals.vex.ctx

fn get_all_tags(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	packages := app.services.tags.get_popular_tags() or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(packages, 200)
}

fn get_tags_packages(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	packages := app.services.tags.get_packages(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(packages, 200)
}

fn admin_create_tag(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	if !authorized(app.user) {
		res.send_status(401)
		return
	}

	if !app.user.is_admin {
		res.send_status(403)
		return
	}

	id := app.services.tags.create(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	send_id(mut res, id)
}

fn admin_delete_tag(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	if !authorized(app.user) {
		res.send_status(401)
		return
	}

	if !app.user.is_admin {
		res.send_status(403)
		return
	}

	app.services.tags.delete(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_status(200)
}
