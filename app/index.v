module app

import vweb
import entity

const packages_view_mock = entity.PackagesView{
	total_count: 248
	new_packages: [
		entity.FullPackage{
			Package: entity.Package {
				id: 1
				name: 'treplo'
				description: 'Logging lib'
				stars: 3
			}
			author: entity.User {
				username: 'Terisback'
			}
		},
	]
	most_downloaded_packages: [
		entity.FullPackage{
			Package: entity.Package {
				id: 1
				name: 'treplo'
				description: 'Logging lib'
				stars: 3
			}
			author: entity.User {
				username: 'Terisback'
			}
		},
	]
	recently_updated_packages: [
		entity.FullPackage{
			Package: entity.Package {
				id: 1
				name: 'treplo'
				description: 'Logging lib'
				stars: 3
			}
			author: entity.User {
				username: 'Terisback'
			}
		},
	]
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
	categories := app.categories_mock.clone()
	view := app.packages_view_mock

	content := $tmpl('./templates/pages/index.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}
