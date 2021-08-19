module app

pub fn (mut app App) before_request() {
	if !app.handle_static('./static', true) {
		panic('folder does not exist or app already end its work')
	}

	// Get token from headers
	// Check is valid
	// Add user to app.user
}
