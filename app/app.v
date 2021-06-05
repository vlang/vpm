module app

import nedpals.vex.router
import nedpals.vex.ctx
import vpm.config
import vpm.models
import vpm.service

struct App {
mut:
	services service.Services
	user models.User
	// github integration
	// auth token manager
}

pub fn new_handler(services service.Services) App {
	return App{
		services: services
	}
}

pub fn (application App) init() router.Router {
	mut app := router.new()

	app.inject(application)

	app.use(clear_user)
	app.use(identity)

	// auth routes

	// app.route(.get, '/categories', dummy)
	// app.route(.get, '/categories/:id', dummy)

	// app.route(.get, '/tags', dummy)
	// app.route(.get, '/tags/:id', dummy)

	// app.route(.get, '/user/:id', dummy)
	// authorized only
	// app.route(.get, '/settings', dummy)
	// admin only
	// app.route(.get, '/user/:id/settings', dummy)

	// app.route(.get, '/search', dummy)
	// app.route(.get, '/package/:id', dummy)
	// app.route(.get, '/package/:id/:version', dummy)
	// authorized only
	// app.route(.get, '/package/:id/settings', dummy)

	app.group('/api', fn (mut router map[string]&router.Route) {

		// auth routes

		router.route(.get, '/categories/', get_all_categories)
		router.route(.get, '/categories/:name', get_category_packages)
		// router.route(.put, '/categories/:name', admin_create_category)
		// router.route(.delete, '/categories/:name', admin_delete_category)

		router.route(.get, '/tags', get_all_tags)
		router.route(.get, '/tags/:name', get_tags_packages)
		router.route(.put, '/tags/:name', admin_create_tag)
		// router.route(.delete, '/tags/:name', admin_delete_tag)

		router.route(.get, '/user/:username', get_user)
		router.route(.put, '/bans/:username', admin_create_user_ban)
		// router.route(.delete, '/bans/:username', admin_delete_user_ban)

		router.route(.get, '/search', dummy)
		router.route(.get, '/package/:name', get_package)
		// router.route(.get, '/package/:name/:version', get_package_version)
		// AUTHOR ONLY
		// router.route(.post, '/package', dummy)
		// router.route(.put, '/package/:name/categories', dummy)
		// router.route(.put, '/package/:name/tags', dummy)
		// router.route(.put, '/package/:name/description', dummy)
		// ADMIN ONLY
		// router.route(.delete, '/package/:name', dummy)
	})

	app.route(.get, '/jsmod/:name', jsmod)

	app.route(.get, '/*filename', fn (req &ctx.Req, mut res ctx.Resp) {
    	filename := req.params['filename']
    	res.send_file('/static/$filename', 200)
    })

	return app
}
