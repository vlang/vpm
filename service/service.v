module service

import repository

pub struct Services {
pub:
	tags     Tags [required]
	packages Packages [required]
	users    Users [required]
}

pub struct Deps {
pub:
	repos repository.Repositories [required]
	// TODO: auth token manager
}

pub fn new_services(deps Deps) Services {
	return Services{
		tags: new_tags(deps.repos.tags, deps.repos.packages)
		packages: new_packages(deps.repos.packages, deps.repos.versions, deps.repos.users)
		users: new_users(deps.repos.users)
	}
}
