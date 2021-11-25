module app

// pub fn (mut app App) before_request() {
// 	if !app.handle_static('./static', true) {
// 		panic('`static` folder does not exist')
// 	}

// 	// Get token from headers
// 	// Check is valid
// 	// Add user to app.user
// }

pub fn (mut app App) authorized() bool {
	return app.user.id != 0
}
