module repository

import pg

pub struct Repositories {
pub:
	keywords Keywords
	packages Packages
	// tokens     &Tokens
	users    Users
	versions Versions
}

pub fn new_repositories(db pg.DB) Repositories {
	return Repositories{
		keywords: new_keywords(db)
		packages: new_packages(db)
		// tokens: new_tokens(db)
		users: new_users(db)
		versions: new_versions(db)
	}
}
