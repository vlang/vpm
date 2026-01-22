module main

import veb
import lib.log
import lib.storage
import lib.html
import markdown
import entity { Package }

@['/new']
fn (app &App) new(mut ctx Context) veb.Result {
	ctx.title = 'Creating package | vpm'
	return $veb.html()
}

@['/create_package'; post]
pub fn (app &App) create_package(mut ctx Context, name string, url string, description string) veb.Result {
	app.packages().create(name, url, description, ctx.cur_user) or {
		log.error()
			.add('error', err.str())
			.add('url', url)
			.add('name', name)
			.add('description', description)
			.add('user_id', ctx.cur_user.id)
			.msg('error creating package')

		// app.error(err.msg())
		// return app.new()
		return ctx.text(err.msg())
	}

	return ctx.redirect('/')
}

@['/users/:name']
pub fn (app &App) user(mut ctx Context, name string) veb.Result {
	user := app.users().get_by_name(name) or {
		error_msg := 'User not found'
		return ctx.html($tmpl('./templates/error.html'))
		// return $veb.html('./templates/error.html') // XTODO
	}

	ctx.title = user.username + ' packages | vpm'

	packages := app.packages().find_by_user(user.id)

	return $veb.html()
}

@['/packages']
pub fn (app &App) packages_redir(mut ctx Context) veb.Result {
	return ctx.redirect('/search')
}

@['/packages/:name']
pub fn (app &App) package(mut ctx Context, name string) veb.Result {
	pkg := app.packages().get(name) or { return ctx.redirect('/') }

	ctx.title = pkg.name + ' | vpm'
	categories := app.packages().get_package_categories(pkg.id) or { [] }

	readme_path := '/packages_readme/${pkg.id}/README.html'
	// pass ctx to helpers if they need request context, otherwise pass nothing
	data := app.get_readme(pkg.name, readme_path) or { '' }

	pkg_readme := data

	return $veb.html()
}

fn (app &App) get_readme(name string, readme_path string) !string {
	data := app.storage.read(readme_path) or {
		if err != storage.err_not_found {
			return error('failed to read readme from storage: ${err}')
		}

		println('fetching readme from repo for `${name}`')

		// TODO: figure out when to update readme
		readme := app.packages().get_package_markdown(name) or {
			return error('failed to get readme from repo: ${err}')
		}

		rendered := html.sanitize(markdown.to_html(readme)).bytes()

		app.storage.save(readme_path, rendered) or {
			println('failed to save readme to storage: ${err}')
		}

		rendered
	}
	return data.bytestr()
}

@['/packages/:name/edit']
pub fn (mut app App) edit(mut ctx Context, name string) veb.Result {
	pkg := app.packages().get(name) or {
		// app.error(err.msg()) // TODO
		// return app.edit(mut ctxname)
		return ctx.text('db error')
	}

	ctx.title = 'Editing «${pkg.name}» | vpm'
	if !ctx.is_able_to_edit(pkg) {
		return ctx.redirect('/packages/${name}')
	}

	pkg_name := pkg.name.split('.')[1] or { pkg.name }

	return $veb.html()
}

@['/packages/:name/edit'; POST]
pub fn (mut app App) perform_edit(mut ctx Context, name string) veb.Result {
	pkg := app.packages().get(name) or {
		// app.error(err.msg())
		// return app.edit(name)
		return ctx.text('db error')
	}

	if !ctx.is_able_to_edit(pkg) {
		return ctx.redirect('/packages/${name}')
	}

	mut pkg_name := ctx.form['name'] or {
		return ctx.text('package name not been provided')
		// return app.edit(name)
	}

	url := ctx.form['url'] or { pkg.url }
	description := ctx.form['description'] or { pkg.description }
	app.packages().update_package_info(pkg.id, pkg_name, url, description) or {
		return ctx.text('package cant be udpated')
		// app.error(err.msg())
		// return app.edit(name)
	}

	return ctx.redirect('/')
}

@['/packages/:name/delete']
pub fn (mut app App) delete(mut ctx Context, name string) veb.Result {
	pkg := app.packages().get(name) or {
		// app.error(err.msg())
		// return app.delete(name)
		return ctx.text('package cant be deleted')
	}

	ctx.title = 'Deleting «${pkg.name}» | vpm'

	if !ctx.is_able_to_edit(pkg) {
		return ctx.redirect('/packages/${name}')
	}

	return $veb.html()
}

@['/packages/:name/delete'; POST]
pub fn (mut app App) perform_delete(mut ctx Context, name string) veb.Result {
	pkg := app.packages().get(name) or {
		// app.error(err.msg())
		// return app.delete(name)
		return ctx.text('package not be deleted')
	}

	if !ctx.is_able_to_edit(pkg) {
		return ctx.redirect('/packages/${name}')
	}

	pkg_name := ctx.form['name'] or { '' }

	if pkg_name != pkg.name {
		// ctx.error('name is not matching')
		// return app.delete(name)
		return ctx.text('name is not matching')
	}

	user_id := if ctx.cur_user.is_admin { pkg.user_id } else { ctx.cur_user.id }
	app.packages().delete(pkg.id, user_id) or {
		// app.error(err.msg())
		// return app.delete(name)
		return ctx.text('can not delete package')
	}

	return ctx.redirect('/')
}

fn (ctx &Context) is_able_to_edit(pkg Package) bool {
	return ctx.cur_user.is_admin || ctx.cur_user.id == pkg.user_id
}
