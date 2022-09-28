module app

import vweb
import lib.log

// Backward compatibility for V <=0.3
['/jsmod/:name'; get]
fn (mut ctx Ctx) jsmod(name string) vweb.Result {
	splitted := name.split_nth('.', 1)

	username := if splitted.len > 1 { splitted[0] } else { '' }
	package := if splitted.len == 1 { splitted[0] } else { splitted[1] }

	old_package := ctx.package.old_package(username, package) or {
		log.error()
			.add('name', name)
			.add('username', username)
			.add('package', package)
			.add('error', err.str())
			.msg('tried to get module')

		return send_json(mut ctx, .not_found, json_error('not found'))
	}

	return ctx.json(old_package)
}

['/new'; get]
fn (mut ctx Ctx) new_package_page() vweb.Result {
	if isnil(ctx.claims) {
		return ctx.redirect(ctx.config.root_url + '/login')
	}

	results := search_results_mock.clone()

	content := $tmpl('./templates/pages/new.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}

['/~:username/:package'; get]
fn (mut ctx Ctx) package(username string, package string) vweb.Result {
	usr := username.trim_left('@~')

	pkg := ctx.package.full_package(usr, package) or {
		log.error()
			.add('username', usr)
			.add('package', package)
			.add('error', err.str())
			.msg('tried to get package')

		ctx.message = 'Package `${usr}.$package` does not exist'
		content := $tmpl('./templates/pages/not_found.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .ok, layout)
	}

	ctx.to_meta += '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/notyf@3/notyf.min.css">\n'
	content := $tmpl('./templates/pages/package.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}

['/api/users/:username/packages'; get]
fn (mut ctx Ctx) api_packages(username string) vweb.Result {
	user := ctx.user.get_by_username(username) or {
		log.error()
			.add('username', username)
			.add('error', err.str())
			.msg('tried to get user')

		return send_json(mut ctx, .not_found, json_error('not found'))
	}

	pkgs := ctx.package.get_by_author(user.id) or {
		log.error()
			.add('username', username)
			.add('error', err.str())
			.msg('tried to get packages by author')

		return send_json(mut ctx, .not_found, json_error('not found'))
	}

	return ctx.json(pkgs)
}

['/api/users/:username/packages/:package'; get]
fn (mut ctx Ctx) api_package(username string, package string) vweb.Result {
	pkg := ctx.package.full_package(username, package) or {
		log.error()
			.add('username', username)
			.add('package', package)
			.add('error', err.str())
			.msg('tried to get package')

		return send_json(mut ctx, .not_found, json_error('not found'))
	}

	return ctx.json(pkg)
}
