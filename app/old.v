module app

import json
import web

// Backward compatibility for V <=0.2.x
['/jsmod/:name'; get]
fn (mut app App) jsmod(name string) web.Result {
	old_package := app.services.packages.get_old_package(name) or {
		return wrap_service_error(mut app, err)
	}

	println('`$old_package.name` cloned...')
	return app.json(.ok, json.encode(old_package))
}
