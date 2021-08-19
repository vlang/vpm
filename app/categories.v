module app

import json
import vweb

[get]
['/api/categories']
fn (mut app App) get_all_categories() vweb.Result {
	categories := app.services.categories.get_popular_categories() or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(categories))
}

[get]
['/api/categories/:name']
fn (mut app App) get_category_packages(name string) vweb.Result {
	packages := app.services.categories.get_packages(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(packages))
}

[post]
['/api/categories/:name']
fn (mut app App) admin_create_category(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	id := app.services.categories.create(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json('{"id": $id)}')
}

[delete]
['/api/categories/:name']
fn (mut app App) admin_delete_category(name string) vweb.Result {
	if !authorized(app.user) {
		app.set_status(401, 'Unauthorized')
		return app.not_found()
	}

	if !app.user.is_admin {
		app.set_status(403, 'Forbidden')
		return app.not_found()
	}

	app.services.categories.delete(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.ok('')
}
