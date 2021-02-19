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