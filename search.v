module main

import veb

@['/search']
pub fn (app &App) search(mut ctx Context) veb.Result {
	query := ctx.query['q']
	sort := ctx.query['sort']

	title := if query == '' { 'All Packages' } else { 'Search Results' }
	ctx.title = title + ' | vpm'

	packages := app.packages().query(query, sort)

	return $veb.html()
}
