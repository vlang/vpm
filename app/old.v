module app

import json
import vweb

// Backward compatibility for V <=0.2.2
['/jsmod/:name'; get]
fn (mut app App) jsmod(name string) vweb.Result {
	package := app.db.packages.get_by_name(name) or {
		return wrap_service_error(mut app, err)
	}

	return app.json(json.encode(package.get_old_package()))
}
