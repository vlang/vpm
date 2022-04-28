module app

import vweb

['/search'; get]
fn (mut app App) search() vweb.Result {
	content := $tmpl('./templates/pages/search.html')
	layout := $tmpl('./templates/layout.html')
	return app.html(layout)
}

['/api/search'; get]
fn (mut app App) api_search() vweb.Result {
	return send_text(mut app, .ok, 'search placeholder')
}