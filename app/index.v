module app

import vweb
import entity
import lib.log

const packages_view_mock = entity.PackagesView{
	total_count: 248
	new_packages: [
		entity.FullPackage{
			Package: entity.Package {
				id: 1
				name: 'treplo'
				description: 'Placeholder'
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
				description: 'Placeholder'
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
				description: 'Placeholder'
				stars: 3
			}
			author: entity.User {
				username: 'Terisback'
			}
		},
	]
}

// Homepage frontend
['/'; get]
fn (mut ctx Ctx) index() vweb.Result {
	categories := ctx.package.categories() or {
		log.error()
			.add('error', err.str())
			.msg('tried to get categories')

		[]entity.Category{}
	}

	view := app.packages_view_mock

	content := $tmpl('./templates/pages/index.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}
