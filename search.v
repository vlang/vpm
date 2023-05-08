module main

import vweb

pub fn (mut app App) search() vweb.Result {
	q := app.query['q']
	title := if q == '' { 'All Packages' } else { 'Search Results' }
	packages := app.find_all_packages_by_query(q)
	return $vweb.html()
}
