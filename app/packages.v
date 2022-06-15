module app

import vweb
import models

struct Package {
	models.Package
pub:
	version string
}

// Module frontend
['/package/:name'; get]
fn (mut app App) package(name string) vweb.Result {
	content := $tmpl('./templates/pages/package.html')
	layout := $tmpl('./templates/layout.html')
	return app.html(layout)
}

fn (mut app App) get_package(id int) Package {
	package := rlock app.services {
		app.services.packages.get_by_id(id) or { models.Package{} }
	}
	version := rlock app.services {
		app.services.packages.get_latest_version(id) or { models.Version{} }
	}
	return Package{package, version.semver}
}

['/api/package/:name'; get]
fn (mut app App) api_package(name string) vweb.Result {
	package := rlock app.services {
		app.services.packages.get_by_name(name) or { return wrap_service_error(mut app, err) }
	}

	return app.json(package)
}

['/api/package/:name/versions'; get]
fn (mut app App) api_package_versions(name string) vweb.Result {
	versions := rlock app.services {
		package := app.services.packages.get_by_name(name) or {
			return wrap_service_error(mut app, err)
		}
		app.services.packages.get_versions(package.id) or {
			return wrap_service_error(mut app, err)
		}
	}

	return app.json(versions)
}

['/api/package'; get]
fn (mut app App) api_most_downloadable_packages() vweb.Result {
	packages := rlock app.services {
		app.services.packages.get_most_downloadable() or {
			return wrap_service_error(mut app, err)
		}
	}

	return app.json(packages)
}
