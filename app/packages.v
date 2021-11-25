module app

import json
import web
import models

struct Package {
	models.Package
pub:
	version string
}

pub fn (mut app App) fpackage(id int) Package {
	package := app.services.packages.get_by_id(id) or { models.Package{} }
	version := app.services.packages.get_lastest_version(id) or { models.Version{} }
	return Package{package, version.tag}
}

['/api/package/:name'; get]
fn (mut app App) api_package(name string) web.Result {
	package := app.services.packages.get_by_name(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(.ok, json.encode(package))
}

['/api/package/:name/versions'; get]
fn (mut app App) api_package_versions(name string) web.Result {
	package := app.services.packages.get_by_name(name) or {
		return wrap_service_error(mut app, err)
	}
	versions := app.services.packages.get_versions(package.id) or {
		return wrap_service_error(mut app, err)
	}
	return app.json(.ok, json.encode(versions))
}

['/api/package'; get]
fn (mut app App) api_most_downloadable_packages() web.Result {
	packages := app.services.packages.get_most_downloadable() or {
		return wrap_service_error(mut app, err)
	}

	return app.json(.ok, json.encode(packages))
}
