module app

import json
import vweb

['/api/tags'; get]
fn (mut app App) get_all_tags() vweb.Result {
	tags := app.db.tags.get_popular_tags() or { return wrap_service_error(mut app, err) }

	return app.json(json.encode(tags))
}

['/api/tags/:name'; get]
fn (mut app App) get_tag_packages(name string) vweb.Result {
	packages := app.db.tags.get_packages(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(packages))
}

['/api/tags/:name'; post]
fn (mut app App) admin_create_tag(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	id := app.db.tags.create(name) or { return wrap_service_error(mut app, err) }

	return app.json('{"id": $id)}')
}

['/api/tags/:name'; delete]
fn (mut app App) admin_delete_tag(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	app.db.tags.delete(name) or { return wrap_service_error(mut app, err) }

	return app.ok('')
}
