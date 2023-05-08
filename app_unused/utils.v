module app

import net.http
import vweb

struct JsonError {
pub mut:
	message string
}

fn json_error(message string) JsonError {
	return JsonError{
		message: message
	}
}

// Set status
fn set_status(mut ctx Ctx, status http.Status) &Ctx {
	ctx.set_status(status.int(), status.str())
	return ctx
}

// Send status text `text/plain` with status
fn send_status(mut ctx Ctx, status http.Status) vweb.Result {
	return send_text(mut ctx, status, status.str())
}

// Send `text/html` with status
fn send_html(mut ctx Ctx, status http.Status, html string) vweb.Result {
	set_status(mut ctx, status)
	return ctx.html(html)
}

// Send `text/plain` with status
fn send_text(mut ctx Ctx, status http.Status, text string) vweb.Result {
	set_status(mut ctx, status)
	return ctx.text(text)
}

// Send `application/json` with status
fn send_json[T](mut ctx Ctx, status http.Status, obj T) vweb.Result {
	set_status(mut ctx, status)
	return ctx.json(obj)
}
