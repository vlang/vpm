module app

import json
import vweb
import models

// Package struct that returns from api
pub struct Package {
	models.Package
pub:
	tags       []models.Tag
	categories []models.Category
	versions   []models.Version
}

['/api/package/:name'; get]
fn (mut app App) get_package(name string) vweb.Result {
	package := app.services.packages.get_by_name(name) or {
		return wrap_service_error(mut app, err)
	}

	tags := app.services.tags.get_by_package(package.id) or {
		// if err !is service.NotFoundError {
		// 	return wrap_service_error(mut app, err)
		// } else {
		// 	[]models.Tag{}
		// }
		[]models.Tag{}
	}

	categories := app.services.categories.get_by_package(package.id) or {
		// if err !is service.NotFoundError {
		// 	return wrap_service_error(mut app, err)
		// } else {
		// 	[]models.Category{}
		// }
		[]models.Category{}
	}

	versions := app.services.versions.get_by_package(package.id) or {
		// if err !is service.NotFoundError {
		// 	return wrap_service_error(mut app, err)
		// } else {
		// 	[]models.Version{}
		// }
		[]models.Version{}
	}

	result := Package{
		Package: package
		tags: tags
		categories: categories
		versions: versions
	}

	return app.json(json.encode(result))
}

['/api/package'; get]
fn (mut app App) get_new_packages() vweb.Result {
	packages := app.services.packages.get_new_packages() or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(packages))
}
