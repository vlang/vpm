module app

import web

['/search'; get]
fn (mut app App) search() web.Result {
	return app.text(.ok, 'search page placeholder')
}

['/api/search'; get]
fn (mut app App) api_search() web.Result {
	return app.text(.ok, 'search placeholder')
}
