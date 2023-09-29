module main

import vweb
import lib.log
import lib.storage
import lib.html
import markdown
import entity { Package }

['/new']
fn (mut app App) new() vweb.Result {
	return $vweb.html()
}

['/create_package'; post]
pub fn (mut app App) create_package(name string, url string, description string) vweb.Result {
	app.packages().create(name, url, description, app.cur_user) or {
		log.error()
			.add('error', err.str())
			.add('url', url)
			.add('name', name)
			.add('description', description)
			.add('user_id', app.cur_user.id)
			.msg('error creating package')

		app.error(err.msg())
		return app.new()
	}

	return app.redirect('/')
}

['/users/:name']
pub fn (mut app App) user(name string) vweb.Result {
	user := app.users().get_by_name(name) or {
		error_msg := 'Not found such user'
		return app.html($tmpl('./templates/error.html'))
	}

	packages := app.packages().find_by_user(user.id)

	return $vweb.html()
}

['/packages']
pub fn (mut app App) packages_redir() vweb.Result {
	return app.redirect('/search')
}

['/packages/:name']
pub fn (mut app App) package(name string) vweb.Result {
	pkg := app.packages().get(name) or {
		println(err)
		return app.redirect('/')
	}

	categories := app.packages().get_package_categories(pkg.id) or { [] }

	// Getting README from repo or storage
	readme_path := '/packages_readme/${pkg.id}/README.html'
	data := app.storage.read(readme_path) or {
		if err != storage.err_not_found {
			println('failed to read readme from storage: ${err}')
			return app.redirect('/')
		}

		println('fetching readme from repo for `${pkg.name}`')

		// TODO: figure out when to update readme
		readme := app.packages().get_package_markdown(name) or {
			println('failed to get readme from repo: ${err}')
			return app.redirect('/')
		}

		rendered := html.sanitize(markdown.to_html(readme)).bytes()

		app.storage.save(readme_path, rendered) or {
			println('failed to save readme to storage: ${err}')
		}

		rendered
	}

	pkg_readme := data.bytestr()

	return app.html($tmpl('./templates/package.html'))
}

['/packages/:name/edit']
pub fn (mut app App) edit(name string) vweb.Result {
	pkg := app.packages().get(name) or {
		app.error(err.msg())
		return app.edit(name)
	}

	if !app.is_able_to_edit(pkg) {
		return app.redirect('/packages/${name}')
	}

	pkg_name := pkg.name.split('.')[1] or { pkg.name }

	return $vweb.html()
}

['/packages/:name/edit'; POST]
pub fn (mut app App) perform_edit(name string) vweb.Result {
	pkg := app.packages().get(name) or {
		app.error(err.msg())
		return app.edit(name)
	}

	if !app.is_able_to_edit(pkg) {
		return app.redirect('/packages/${name}')
	}

	mut pkg_name := app.form['name'] or {
		app.error('package name not been provided')
		return app.edit(name)
	}

	url := app.form['url'] or { pkg.url }
	description := app.form['description'] or { pkg.description }
	app.packages().update_package_info(pkg.id, pkg_name, url, description) or {
		app.error(err.msg())
		return app.edit(name)
	}

	return app.redirect('/')
}

['/packages/:name/delete']
pub fn (mut app App) delete(name string) vweb.Result {
	pkg := app.packages().get(name) or {
		app.error(err.msg())
		return app.delete(name)
	}

	if !app.is_able_to_edit(pkg) {
		return app.redirect('/packages/${name}')
	}

	return $vweb.html()
}

['/packages/:name/delete'; POST]
pub fn (mut app App) perform_delete(name string) vweb.Result {
	pkg := app.packages().get(name) or {
		app.error(err.msg())
		return app.delete(name)
	}

	if !app.is_able_to_edit(pkg) {
		return app.redirect('/packages/${name}')
	}

	pkg_name := app.form['name'] or { '' }

	if pkg_name != pkg.name {
		app.error('name is not matching')
		return app.delete(name)
	}

	user_id := if app.cur_user.is_admin { pkg.user_id } else { app.cur_user.id }
	app.packages().delete(pkg.id, user_id) or {
		app.error(err.msg())
		return app.delete(name)
	}

	return app.redirect('/')
}

fn (mut app App) is_able_to_edit(pkg Package) bool {
	return app.cur_user.is_admin || app.cur_user.id == pkg.user_id
}
