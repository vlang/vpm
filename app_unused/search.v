module app

import vweb
import app_unused.entity
import lib.log

const search_results_mock = [
	entity.FullPackage{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
	},
	entity.FullPackage{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
	},
	entity.FullPackage{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
	},
	entity.FullPackage{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
	},
	entity.FullPackage{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
	},
	entity.FullPackage{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
	},
]

// Rendered search template
['/search'; get]
fn (mut ctx Ctx) search() vweb.Result {
	query := ctx.query['q']
	results := app.search_results_mock.clone()
	total := 243

	title := 'Search results for «${query}» (${total})'

	content := $tmpl('./templates/pages/browser.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}

pub struct APISearchResponse {
pub mut:
	results []entity.FullPackage
	total   int
}

['/api/search'; get]
fn (mut ctx Ctx) api_search() vweb.Result {
	query := ctx.query['q']
	page := ctx.query['page'].int()
	category := ctx.query['category']

	if query.len > 0 && query.len <= 2 {
		return send_json(mut ctx, .bad_request, json_error('`q` length must be greater that 2 and should only contain ASCII alphanumerics, hyphens (-), underscores (_) and periods (.)'))
	}

	results, total := ctx.package.search(query, category, .most_downloaded, page) or {
		log.error()
			.add('query', query)
			.add('page', page)
			.add('error', err.str())
			.msg('tried to search')

		return send_json(mut ctx, .internal_server_error, json_error('internal server error'))
	}

	return ctx.json(APISearchResponse{
		results: results
		total: total
	})
}
