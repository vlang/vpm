module app

import vweb
import vpm.lib.log

// Rendered search template
['/categories'; get]
fn (mut ctx Ctx) categories() vweb.Result {
	categories := ctx.package.categories() or {
		log.error()
			.add('error', err.str())
			.msg('tried to get categories')

		ctx.message = "No categories found..."
		content := $tmpl('./templates/pages/error.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .internal_server_error, layout)
	}

	content := $tmpl('./templates/pages/categories.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}

['/categories/:slug'; get]
fn (mut ctx Ctx) category(slug string) vweb.Result {
	page := ctx.query['page'].int()

	results, total := ctx.package.category(slug, .most_downloaded, page) or {
		log.error()
			.add('slug', slug)
			.add('page', page)
			.add('error', err.str())
			.msg('tried to get packages with category')

		ctx.message = "Zero results for «$slug» category found..."
		content := $tmpl('./templates/pages/error.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .not_found, layout)
	}

	title := "Results for «$slug» category ($total)"
	content := $tmpl('./templates/pages/browser.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}

['/api/categories'; get]
fn (mut ctx Ctx) api_categories() vweb.Result {
	categories := ctx.package.categories() or {
		log.error()
			.add('error', err.str())
			.msg('tried to get categories')

		return send_json(mut ctx, .internal_server_error, json_error(err.str()))
	}

	return ctx.json(categories)
}

['/api/categories/:slug'; get]
fn (mut ctx Ctx) api_category_packages(slug string) vweb.Result {
	page := ctx.query['page'].int()

	packages, _ := ctx.package.category(slug, .most_downloaded, page) or {
		log.error()
			.add('slug', slug)
			.add('page', page)
			.add('error', err.str())
			.msg('tried to get packages with category')

		return send_json(mut ctx, .not_found, json_error(err.str()))
	}

	return ctx.json(packages)
}
