module service

import time
import models
import repository

pub interface Categories {
	create(name string) ?int
	get_by_id(id int) ?models.Category
	get_by_name(name string) ?models.Category
	get_by_package(id int) ?[]models.Category
	get_packages(name string) ?[]models.Package
	get_popular_categories() ?[]models.Category
	get_all() ?[]models.Category
	add_package(id int, package_id int) ?
	delete(name string) ?
}

pub struct CreatePackageInput {
pub:
	author_id   int    [json: authorId]
	name        string
	description string
	license     string
	vcs         string
	repo_url    string [json: repoUrl]
}

pub interface Packages {
	create(input CreatePackageInput) ?int
	get_by_id(id int) ?models.Package
	get_by_name(name string) ?models.Package
	get_by_author(author_id int) ?[]models.Package
	set_description(name string, description string) ?
	set_stars(name string, stars int) ?
	add_download(name string) ?
	delete(name string) ?
	get_most_downloadable() ?[]models.Package
	get_most_recent_downloads() ?[]models.Package
	get_new_packages() ?[]models.Package
	get_recently_updated() ?[]models.Package
	get_packages_count() ?int
}

pub interface Tags {
	create(name string) ?int
	get_by_id(id int) ?models.Tag
	get_by_name(name string) ?models.Tag
	get_by_package(id int) ?[]models.Tag
	get_packages(name string) ?[]models.Package
	get_popular_tags() ?[]models.Tag
	get_all() ?[]models.Tag
	add_package(id int, package_id int) ?
	delete(name string) ?
}

pub struct CreateUserInput {
pub:
	github_id  int
	name       string
	username   string
	avatar_url string [json: avatarUrl]
}

pub struct UpdateUserInput {
pub:
	github_id  int
	name       string
	username   string
	avatar_url string
}

pub interface Users {
	create(input CreateUserInput) ?int // returns user id
	get_by_id(id int) ?models.User
	get_by_github_id(id int) ?models.User
	get_by_username(username string) ?models.User
	get_packages(id int) ?[]models.Package
	update(input UpdateUserInput) ?
	set_blocked(id int, is_blocked bool) ?
	set_admin(id int, is_admin bool) ?
	update_token(github_id int, access_token string) ?int // returns user id
	verify(jwt_token string) ?int // returns user id
}

pub struct CreateVersionInput {
pub:
	package_id   int       [json: packageId]
	name         string
	commit_hash  string    [json: commitHash]
	release_url  string    [json: releaseUrl]
	dependencies []int
	date         time.Time
}

pub interface Versions {
	create(input CreateVersionInput) ?int
	get(package_id int, name string) ?models.Version
	get_by_id(id int) ?models.Version
	get_by_package(package_id int) ?[]models.Version
	add_download(name string) ?
	delete(name string) ?
}

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
		categories: new_categories_service(deps.repos.categories, deps.repos.packages)
		packages: new_packages_service(deps.repos.packages)
		tags: new_tags_service(deps.repos.tags, deps.repos.packages)
		users: new_users_service(deps.repos.users, deps.repos.packages)
		versions: new_versions_service(deps.repos.versions)
	}
}
