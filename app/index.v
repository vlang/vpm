module app

import vweb
import vpm.entity

const packages_view_mock = entity.PackagesView {
	total_count: 248,
	new_packages: [
		entity.FullPackage{
			id: 1
			name: 'treplo'
			description: 'Logging lib'
			stars: 3
		},
	],
	most_downloaded_packages: [
		entity.FullPackage{
			id: 1
			name: 'treplo'
			description: 'Logging lib'
			stars: 3
		},
	],
	recently_updated_packages: [
		entity.FullPackage{
			id: 1
			name: 'treplo'
			description: 'Logging lib'
			stars: 3
		},
	],
}

const categories_mock = [
	entity.Category{
		slug: 'http'
		packages: 101
	},
]

// Homepage frontend
['/'; get]
fn (mut ctx Ctx) index() vweb.Result {
	categories := categories_mock.clone()
	view := packages_view_mock

	content := $tmpl('./templates/pages/index.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}
