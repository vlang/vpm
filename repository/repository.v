module repository

import pg

pub struct Repositories {
pub:
	categories &Categories
	packages   &Packages
	versions   &Versions
	tags       &Tags
	// tokens     &Tokens
	users      &Users
}

pub fn new_repositories(db pg.DB) Repositories {
	return Repositories{
		categories: new_categories(db)
		packages: new_packages(db)
		versions: new_versions(db)
		tags: new_tags(db)
		// tokens: new_tokens(db)
		users: new_users(db)
	}
}
