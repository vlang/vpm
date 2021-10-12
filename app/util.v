module app

import vweb
import service

fn wrap_service_error(mut app App, err IError) vweb.Result {
	match err {
		service.NotFoundError {
			return vweb.not_found()
		}
		// Also known as constraint error
		service.AlreadyExists {
			app.set_status(422, 'Already exists')
			return app.not_found()
		}
		else {
			app.set_status(500, err.msg)
			return app.server_error(500)
		}
	}
}

// fn errout(req &ctx.Req, err IError) {
// 	eprintln('[ERR][$time.now().hhmmss()] $req.method $req.path : $err')
// }
