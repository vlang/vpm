module main

import vweb
import time

pub fn (mut app App) index() vweb.Result {
	// Cachable index page
	if app.last_update == unsafe { nil } || app.last_update < time.now().add(-time.minute) {
		p := app.packages()
		app.categories = p.get_categories() or { [] }
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

	return $vweb.html()
}

pub fn (mut app App) nr_pkgs() string {
	return *app.nr_packages
}
