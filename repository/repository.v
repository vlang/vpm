module repository

import sqlite
import models

pub interface Categories {
	create(name string) ?int
	get_by_id(id int) ?models.Category
	get_by_name(name string) ?models.Category
	get_by_package(id int) ?[]models.Category
	get_packages(name string) ?[]int
	get_popular_categories() ?[]models.Category
	get_all() ?[]models.Category
	add_package(id int, package_id int) ?
	delete(name string) ?
}

pub interface Packages {
	create(package models.Package) ?int
	get_by_id(id int) ?models.Package
	get_by_ids(id ...int) ?[]models.Package
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

pub interface Versions {
	create(version models.Version) ?int
	get(package_id int, name string) ?models.Version
	get_by_id(id int) ?models.Version
	get_by_package(package_id int) ?[]models.Version
	add_download(name string) ?
	delete(name string) ?
}

pub interface Tags {
	create(name string) ?int
	get_by_id(id int) ?models.Tag
	get_by_name(name string) ?models.Tag
	get_by_package(id int) ?[]models.Tag
	get_packages(name string) ?[]int
	get_popular_tags() ?[]models.Tag
	get_all() ?[]models.Tag
	add_package(id int, package_id int) ?
	delete(name string) ?
}

pub interface Tokens {
	update(user_id string, access_token string) ?
	get(user_id string) ?models.Token
	delete(user_id string) ?
}

pub interface Users {
	create(user models.User) ?int
	get_by_id(id int) ?models.User
	get_by_github_id(id int) ?models.User
	get_by_username(username string) ?models.User
	update(user models.User) ?
	set_blocked(id int, is_blocked bool) ?
	set_admin(id int, is_admin bool) ?
}

pub struct Repositories {
pub:
	categories Categories
	packages   Packages
	versions   Versions
	tags       Tags
	tokens     Tokens
	users      Users
}

pub fn new_repositories(db sqlite.DB) Repositories {
	return Repositories{
		categories: new_categories_repo(db)
		packages: new_packages_repo(db)
		versions: new_versions_repo(db)
		tags: new_tags_repo(db)
		tokens: new_tokens_repo(db)
		users: new_users_repo(db)
	}
}
