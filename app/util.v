module app

import web
import service

fn wrap_service_error(mut app App, err IError) web.Result {
	match err {
		service.NotFoundError {
			return app.send_status(.not_found)
		}
		// Also known as constraint error
		service.AlreadyExists {
			return app.send_status(.unprocessable_entity)
		}
		else {
			return app.send_status(.internal_server_error)
		}
	}
}

// fn errout(req &ctx.Req, err IError) {
// 	eprintln('[ERR][$time.now().hhmmss()] $req.method $req.path : $err')
// }
