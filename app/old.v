module app

import json
import web
// import github

// Backward compatibility for V <=0.2.2
['/jsmod/:name'; get]
fn (mut app App) jsmod(name string) web.Result {
	// repo := github.get_repo_by_id(package.gh_repo_id) or {
	// 	return wrap_service_error(mut app, err)
	// }

	old_package := app.services.packages.get_old_package(name) or {
		return wrap_service_error(mut app, err)
	}
	println('`$old_package` cloned...')
	return app.json(.ok, json.encode(old_package))
	// return app.json(.ok, json.encode(models.OldPackage{
	// 	...old_package
	// 	url: repo.clone_url
	// }))
}
