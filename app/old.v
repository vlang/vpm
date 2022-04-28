module app

import vweb

// Backward compatibility for V <=0.2.x
['/jsmod/:name'; get]
fn (mut app App) jsmod(name string) vweb.Result {
	old_package := rlock app.services {
		app.services.packages.get_package_old(name) or {
			return wrap_service_error(mut app, err)
		}
	}
	return app.json(old_package)
}
