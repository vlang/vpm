module app

import nedpals.vex.ctx

// Backward compatibility for V <=0.2.2
fn jsmod(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	package := app.services.packages.get_by_name(req.params['name']) or {
		wrap_service_error(req, mut res, err)
		return
	}

	res.send_json(package.get_old_package(), 200)
}
