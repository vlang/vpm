module main

import veb
import lib.log
import lib.storage
import lib.html
import markdown
import entity { Package }
import time
import usecase.package as package_readme

const readme_cache_lifetime_seconds = 24 * 60 * 60

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
		ctx.error(err.msg())
		return app.new(mut ctx)
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

// package renders the package page with the repository's cached README.
@['/packages/:name']
pub fn (app &App) package(mut ctx Context, name string) veb.Result {
	pkg := app.packages().get(name) or { return ctx.redirect('/') }

	ctx.title = pkg.name + ' | vpm'
	categories := app.packages().get_package_categories(pkg.id) or { [] }

	readme_path := '/packages_readme/${pkg.id}/README.html'
	data := get_readme(app.storage, readme_path, fn [pkg] () !string {
		return package_readme.fetch_markdown(pkg.url)
	}) or { '' }

	pkg_readme := veb.RawHtml(data)

	return $veb.html()
}

fn get_readme(cache storage.Provider, path string, fetch fn () !string) !string {
	cached := cache.read(path) or {
		if err != storage.err_not_found {
			return error('failed to read readme from storage: ${err}')
		}
		storage.Entry{}
	}
	if cached.modified_at > time.now().unix() - readme_cache_lifetime_seconds {
		return cached.data.bytestr()
	}

	readme := fetch() or {
		log.error().add('error', err.str()).add('path', path).msg('failed to fetch readme')
		return cached.data.bytestr()
	}
	rendered := if readme.trim_space() == '' {
		''
	} else {
		html.sanitize(markdown.to_html(readme))
	}

	cache.save(path, rendered.bytes()) or {
		println('failed to save readme to storage: ${err}')
	}

	return rendered
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

// perform_edit updates the package details submitted by an authorized user.
@['/packages/:name/edit'; post]
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
	app.packages().update_package_info(pkg.id, pkg_name, url, description, ctx.cur_user.is_admin) or {
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

// perform_delete deletes the package after an authorized user confirms its name.
@['/packages/:name/delete'; post]
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

	app.packages().delete(pkg.id, ctx.cur_user.id, ctx.cur_user.is_admin) or {
		// app.error(err.msg())
		// return app.delete(name)
		return ctx.text('can not delete package')
	}

	return ctx.redirect('/')
}

fn (ctx &Context) is_able_to_edit(pkg Package) bool {
	return ctx.cur_user.is_admin || ctx.cur_user.id == pkg.user_id
}
