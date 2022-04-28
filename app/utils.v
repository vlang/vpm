module app

import vweb
import net.http
import service

fn wrap_service_error(mut app App, err IError) vweb.Result {
	match err {
		service.NotFoundError {
			return send_status(mut app, .not_found)
		}
		// Also known as constraint error
		service.AlreadyExists {
			return send_status(mut app, .unprocessable_entity)
		}
		else {
			return send_status(mut app, .internal_server_error)
		}
	}
}

// Set status
fn set_status(mut app App, status http.Status) {
	app.set_status(status.int(), status.str())
}

// Send status
fn send_status(mut app App, status http.Status) vweb.Result {
	// ! It's workaround, don't do that, use vex
	status_text := status.str()
	app.set_status(status.int(), status_text)
	return app.text(status_text)
}

// Send text with status
fn send_text(mut app App, status http.Status, text string) vweb.Result {
	app.set_status(status.int(), status.str())
	return app.text(text)
}

// fn errout(req &ctx.Req, err IError) {
// 	eprintln('[ERR][$time.now().hhmmss()] $req.method $req.path : $err')
// }
