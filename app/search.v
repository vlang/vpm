module app

import nedpals.vex.ctx

fn search(req &ctx.Req, mut res ctx.Resp) {
	mut app := &App(req.ctx)

	res.send('ass', 200)
}
