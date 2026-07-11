module main

import veb
import time

pub fn (mut app App) index(mut ctx Context) veb.Result {
	// Cachable index page
	// Note: app.last_update is a pointer in the struct, so we dereference to check
	if app.last_update == unsafe { nil } || *app.last_update < time.now().add(-time.minute) {
		p := app.packages()
		app.categories = p.get_categories() or { [] }
		app.categories.trim(12)
		app.new_packages = p.get_new_packages()
		app.recently_updated_packages = p.get_recently_updated_packages()
		app.most_downloaded_packages = p.get_most_downloaded_packages()
		unsafe {
			nr := '${p.get_packages_count()} packages'
			n := time.now()
			app.nr_packages = &nr
			app.last_update = &n
		}
	}

	// In templates, you access fields via the receiver variable name usually,
	// or pass them explicitly.
	// veb templates usually capture local variables.
	// Ensure the template uses `app.categories`, `ctx.cur_user`, etc.

	return $veb.html()
}

pub fn (mut app App) nr_pkgs() string {
	return *app.nr_packages
}
