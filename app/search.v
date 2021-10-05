module app

import vweb

['/search'; get]
fn (mut app App) search() vweb.Result {
}

['/api/search'; get]
fn (mut app App) api_search() vweb.Result {
	return app.ok('search placeholder')
}
