module app

import vweb
import models

// Homepage frontend
['/'; get]
fn (mut app App) index() vweb.Result {
	search_tags := [
		models.Tag {
			slug:"web"
			packages:23
		},
		models.Tag {
			slug:"cli"
			packages:98
		},
		models.Tag {
			slug:"database"
			packages:41
		},
		models.Tag {
			slug:"gamedev"
			packages:48
		},
		models.Tag {
			slug:"graphics"
			packages:4
		},
		models.Tag {
			slug:"wrapper"
			packages:198
		},
		models.Tag {
			slug:"binding"
			packages:56
		},
		models.Tag {
			slug:"parsing"
			packages:3
		},
		models.Tag {
			slug:"http"
			packages:19
		},
		models.Tag {
			slug:"io"
			packages:69
		},
		models.Tag {
			slug:"http-router"
			packages:3
		},
	]

	new_packages := [
		models.Package{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
		}
	]

	most_downloaded_packages := [
		models.Package{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
		}
	]

	recently_updated_packages := [
		models.Package{
		id: 1
		name: 'treplo'
		description: 'Logging lib'
		stars: 3
		}
	]

	total_packages := 232
	
	content := $tmpl('./templates/pages/index.html')
	layout := $tmpl('./templates/layout.html')
	return app.html(layout)
}