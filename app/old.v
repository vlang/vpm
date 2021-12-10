module app

import json
import web
import models

// Backward compatibility for V <=0.2.2
['/jsmod/:name'; get]
fn (mut app App) jsmod(name string) web.Result {
	package := app.services.packages.get_by_name(name) or {
		return wrap_service_error(mut app, err)
	}

	latest_version := app.services.packages.add_download(package.id) or {
		println(err)
		return wrap_service_error(mut app, err)
	}

	println('$package.name@$latest_version.semver downloads: $latest_version.downloads')
	old_package := package.get_old_package()

	return app.json(.ok, json.encode(models.OldPackage{
		...old_package
		nr_downloads: latest_version.downloads
	}))
}
