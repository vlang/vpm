module main

struct User {
	id int
	name string
	username string
	is_admin bool
mut:
	avatar               string
	b_avatar             bool    [skip]
	login_attempts       int
}

pub fn (mut app App) get_user_from_cookies() ?User {
	return error('Not implemented')
}