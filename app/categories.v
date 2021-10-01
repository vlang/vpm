module app

import json
import vweb

['/api/categories'; get]
fn (mut app App) get_all_categories() vweb.Result {
	categories := app.db.categories.get_popular_categories() or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(categories))
}

['/api/categories/:name'; get]
fn (mut app App) get_category_packages(name string) vweb.Result {
	packages := app.db.categories.get_packages(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(packages))
}

['/api/categories/:name'; post]
fn (mut app App) admin_create_category(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	id := app.db.categories.create(name) or { return wrap_service_error(mut app, err) }

	return app.json('{"id": $id)}')
}

['/api/categories/:name'; delete]
fn (mut app App) admin_delete_category(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	app.db.categories.delete(name) or { return wrap_service_error(mut app, err) }

	return app.ok('')
}
