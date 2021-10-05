module service

import repository

pub struct Services {
pub:
	keywords Keywords
	packages Packages
	users    Users
}

pub struct Deps {
pub:
	repos repository.Repositories
	// TODO: auth token manager
}

pub fn new_services(deps Deps) Services {
	return Services{
		keywords: new_keywords(deps.repos.keywords, deps.repos.packages)
		packages: new_packages(deps.repos.packages, deps.repos.versions)
		users: new_users(deps.repos.users, deps.repos.packages)
	}
}
