module app

import github
import vweb

['/webhook/gh'; post]
fn (mut app App) github_webhook() vweb.Result {
	event := github.parse_event(app.req) or {
		println(err)
		return send_status(mut app, .bad_request)
	}

	println('Got event $event')
	return send_status(mut app, .ok)
}
