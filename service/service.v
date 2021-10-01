module service

import time
import models
import repository

pub struct Services {
pub:
	categories Categories
	packages   Packages
	tags       Tags
	users      Users
	versions   Versions
}

pub struct Deps {
pub:
	repos repository.Repositories
	// TODO: auth token manager
}

pub fn new_services(deps Deps) Services {
	return Services{
		categories: new_categories(deps.repos.categories, deps.repos.packages)
		packages: new_packages(deps.repos.packages)
		tags: new_tags(deps.repos.tags, deps.repos.packages)
		users: new_users(deps.repos.users, deps.repos.packages)
		versions: new_versions(deps.repos.versions)
	}
}
