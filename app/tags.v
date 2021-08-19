module app

import json
import vweb

[get]
['/api/tags']
fn (mut app App) get_all_tags() vweb.Result {
	tags := app.services.tags.get_popular_tags() or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(tags))
}

[get]
['/api/tags/:name']
fn (mut app App) get_tag_packages(name string) vweb.Result {
	packages := app.services.tags.get_packages(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(packages))
}

[post]
['/api/tags/:name']
fn (mut app App) admin_create_tag(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	id := app.services.tags.create(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json('{"id": $id)}')
}

[delete]
['/api/tags/:name']
fn (mut app App) admin_delete_tag(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	app.services.tags.delete(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.ok('')
}
