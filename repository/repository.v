module repository

import models

pub interface Categories {
	create(name string) ?int
	get_by_id(id int) ?models.Category
	get_by_name(name string) ?models.Category
	get_packages(id int) ?[]int
	add_package(id int, package_id int) ?
	delete(id int) ?
}

pub interface Packages {
	create(package models.Package) ?int
	get_by_id(id int) ?models.Package
	get_by_name(name string) ?models.Package
	get_by_author(author_id int) ?[]models.Package
	set_description(id int, description string) ?
	set_stars(id int, stars int) ?
	add_nr_downloads(id int) ?
	delete(id int) ?
}

pub interface Versions {
	create(version models.Version) ?int
	get_by_id(id int) ?models.Version
	get_by_name(name string) ?models.Version
	get_by_package(package_id int) ?[]models.Version
	add_nr_downloads(id int) ?
	delete(id int) ?
}

pub interface Tags {
	create(name string) ?int
	get_by_id(id int) ?models.Tag
	get_by_name(name string) ?models.Tag
	get_packages(id int) ?[]int
	add_package(id int, package_id int) ?
	delete(id int) ?
}

pub interface Tokens {
	add_token(user_id int, ip string) ?string
	find_token(user_id int, ip string) ?string
	update_token(token string, user_id int, ip string) ?string
	is_valid(token string, user_id int, ip string) ?bool
	clear_tokens(user_id int) ?
}

pub interface Users {
	create(user models.User) ?int
	get_by_id(id int) ?models.User
	get_by_username(username string) ?models.User
	set_name(id int, name string) ?
	set_username(id int, username string) ?
	set_avatar_url(id int, avatar_url string) ?
}
