module app

import vweb

[get]
['/api/search']
fn (mut app App) search() vweb.Result  {
	return app.ok('search placeholder')
}
