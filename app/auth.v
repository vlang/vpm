module app

import github
import vweb

['/login'; get]
fn (mut app App) login() vweb.Result {
	link := github.OAuthLink{
		client_id: app.config.gh.client_id
		redirect_uri: app.config.root_url + "/authorize"
	}
	return app.redirect(link.web_flow())
}

['/authorize'; get]
fn (mut app App) authorize() vweb.Result {
	println(app.query)
	return app.redirect(app.config.root_url)
}

['/logout'; get]
fn (mut app App) logout() vweb.Result {
	return send_status(mut app, .ok)
}