module app

// import github
import web

['/webhook/gh'; get]
fn (mut app App) github_webhook() web.Result {
	// event := github.parse_event(app.request) or {
	// 	println(err)
	// 	return app.send_status(.ok)
	// }

	// println('Got event $event')

	return app.send_status(.ok)
}
