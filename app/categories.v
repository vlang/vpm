module app

import nedpals.vex.ctx

fn get_all_categories(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	categories := app.services.categories.get_popular_categories() or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(categories, 200)
}

fn get_category_packages(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	name := req.params['name']

	packages := app.services.categories.get_packages(name) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(packages, 200)
}

fn admin_create_category(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	if !authorized(app.user) {
		res.send_status(401)
		return
	}

	if !app.user.is_admin {
		res.send_status(403)
		return
	}

	id := app.services.categories.create(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.headers['Content-Type'] = ['application/json']
	res.send('{"id": $id.str()}', 200)
}

fn admin_delete_category(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	if !authorized(app.user) {
		res.send_status(401)
		return
	}

	if !app.user.is_admin {
		res.send_status(403)
		return
	}

	app.services.categories.delete(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_status(200)
}
