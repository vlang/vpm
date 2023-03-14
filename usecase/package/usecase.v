module package

import config
import entity
import repo
import lib.sql
import lib.log

// Used in search and packages view (index page)
pub const per_page = 6

pub struct UseCase {
	cfg      config.Github
	category repo.CategoryRepo
	package  repo.PackageRepo
	user     repo.UserRepo
}

pub fn new_use_case(cfg config.Github, category repo.CategoryRepo, package repo.PackageRepo, user repo.UserRepo) UseCase {
	return UseCase{
		cfg: cfg
		category: category
		package: package
		user: user
	}
}

pub fn (u UseCase) create(url string) ?entity.Package {
	// Get git repo and extract package info, tags
	return error('not implemented')
}

pub fn (u UseCase) categories() ?[]entity.Category {
	categories := u.category.get_all()?

	log.info()
		.add('count', categories.len)
		.msg('all categories')

	return categories
}

pub fn (u UseCase) category(slug string, order_by OrderBy, page int) ?([]entity.FullPackage, int) {
	category := u.category.get_by_slug(slug)?
	// TODO: paginate
	packages := u.package.get_by_category_id(category.id)?

	offset := page * package.per_page
	mut full_packages := []entity.FullPackage{cap: package.per_page}
	for _, package in packages[offset..offset + package.per_page] {
		full_packages << u.to_full_package(package)?
	}

	log.info()
		.add('slug', slug)
		.add('order_by', order_by.str())
		.add('page', page)
		.add('count', packages.len)
		.msg('packages with category')

	return full_packages, packages.len
}

pub fn (u UseCase) get_by_author(author_id int) ?[]entity.FullPackage {
	packages := u.package.get_by_author(author_id)?

	mut full_packages := []entity.FullPackage{cap: packages.len}
	for _, package in packages {
		full_packages << u.to_full_package(package)?
	}

	log.info()
		.add('author', author_id)
		.add('count', packages.len)
		.msg('packages by author')

	return full_packages
}

pub fn (u UseCase) old_package(username string, package string) ?entity.OldPackage {
	usr := u.user.get_by_username(username)?
	pkg := u.package.get(usr.id, package)?
	name := if pkg.is_flatten { pkg.name } else { '${usr.username}.${pkg.name}' }

	log.info()
		.add('author', usr.id)
		.add('package', pkg.id)
		.add('is_flatten', pkg.is_flatten)
		.add('name', name)
		.msg('old package')

	return entity.OldPackage{
		id: pkg.id
		name: name
		vcs: pkg.vcs
		url: pkg.url
		nr_downloads: pkg.downloads
	}
}

pub fn (u UseCase) full_package(username string, package string) ?entity.FullPackage {
	usr := u.user.get_by_username(username)?
	pkg := u.package.get(usr.id, package)?

	log.info()
		.add('author', usr.id)
		.add('package', pkg.id)
		.add('is_flatten', pkg.is_flatten)
		.msg('full package')

	return u.to_full_package(pkg)
}

pub fn (u UseCase) packages_view() ?entity.PackagesView {
	return error('not implemented')
}

pub fn (u UseCase) search(query string, category string, order_by OrderBy, page int) ?([]entity.FullPackage, int) {
	/*
	packages, total := u.package.search(
		query: query
		offset: package.per_page * page
		limit: package.per_page
		order_by: sql.OrderBy{
			column: order_by.str()
			order: sql.Order.descending
		}
	)?

	mut full_packages := []entity.FullPackage{cap: packages.len}
	for _, package in packages {
		full_packages << u.to_full_package(package)?
	}

	log.info()
		.add('query', query)
		.add('order_by', order_by.str())
		.add('page', page)
		.add('total', total)
		.msg('search results')
	*/

	mut full_packages := []entity.FullPackage{}
	total := 0
	return full_packages, total
}

pub fn (u UseCase) update(package entity.Package) ?entity.Package {
	// TODO: repeat process of create method
	return error('not implemented')
}

fn (u UseCase) to_full_package(package entity.Package) ?entity.FullPackage {
	author := u.user.get(package.author_id)?
	categories := u.category.get_by_package_id(package.id)?

	return entity.FullPackage{
		Package: package
		author: author
		categories: categories
	}
}
