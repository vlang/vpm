module app

import nedpals.vex.ctx
import vpm.models

fn clear_user(mut req ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)
	app.user = models.User{}
}

fn identity(mut req ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)
	// TODO: app.user
}

