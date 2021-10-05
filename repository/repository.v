module repository

import pg

// Helper tables
const (
	version_dependencies_table = 'version_dependencies'
	package_keywords_table     = 'package_keywords'
)

// Helper views
const (
	most_downloadable_view = 'most_downloadable_packages'
)

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
