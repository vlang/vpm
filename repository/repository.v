module repository

import pg

// Helper tables
const (
	version_dependencies_table = 'version_dependencies'
)

// Helper views
const (
	most_downloadable_view = 'most_downloadable_packages'
)

pub struct Repositories {
pub:
	tags     Tags     [required]
	packages Packages [required]
	// tokens     &Tokens
	users    Users    [required]
	versions Versions [required]
}

pub fn new_repositories(db pg.DB) Repositories {
	return Repositories{
		tags: new_tags(db)
		packages: new_packages(db)
		// tokens: new_tokens(db)
		users: new_users(db)
		versions: new_versions(db)
	}
}
