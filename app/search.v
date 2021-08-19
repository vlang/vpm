module app

import vweb

['/api/search'; get]
fn (mut app App) search() vweb.Result {
	return app.ok('search placeholder')
}
