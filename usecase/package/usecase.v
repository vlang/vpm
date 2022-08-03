module package

import vpm.config
import vpm.entity
import vpm.repo
import vpm.lib.sql
import vpm.lib.log

// Used in search and packages view (index page)
pub const per_page = 6

pub struct UseCase {
	cfg config.Github
	category repo.CategoryRepo
	package repo.PackageRepo
	tag repo.TagRepo
	user repo.UserRepo
}

pub fn new_use_case(cfg config.Github, category repo.CategoryRepo, package repo.PackageRepo, tag repo.TagRepo, user repo.UserRepo) UseCase {
	return UseCase{cfg: cfg, category: category, package: package, tag: tag, user: user}
}

pub fn (u UseCase) create(url string) ?entity.Package {
	// Get git repo and extract package info, tags
	return error('not implemented')
}

pub fn (u UseCase) categories() ?[]entity.Category {
	categories := u.category.get_all() ?

	log.info()
		.add('count', categories.len)
		.msg('all categories')

	return categories
}

pub fn (u UseCase) category(slug string, order_by OrderBy, page int) ?([]entity.FullPackage, int) {
	category := u.category.get_by_slug(slug) ?
	// TODO: paginate
	packages := u.package.get_by_category_id(category.id) ?

	offset := page * per_page
	mut full_packages := []entity.FullPackage{cap: per_page}
	for _, package in packages[offset .. offset + per_page] {
		full_packages << u.to_full_package(package) ?
	}

	log.info()
		.add('slug', slug)
		.add('order_by', order_by.str())
		.add('page', page)
		.add('count', packages.len)
		.msg('packages with category')

	return full_packages, packages.len
}

pub fn (u UseCase) old_package(username string, package string) ?entity.OldPackage {
	pkg := u.package.get(username, package) ?
	name := if pkg.is_flatten { pkg.name } else { '${pkg.author}.$pkg.name' }

	log.info()
		.add('author', pkg.author)
		.add('package', pkg.author)
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
	pkg := u.package.get(username, package) ?

	log.info()
		.add('author', pkg.author)
		.add('package', pkg.author)
		.add('is_flatten', pkg.is_flatten)
		.msg('full package')

	return u.to_full_package(pkg)
}

pub fn (u UseCase) packages_view() ?entity.PackagesView {
	return error('not implemented')
}

pub fn (u UseCase) search(query string, order_by OrderBy, page int) ?([]entity.FullPackage, int) {
	packages, total := u.package.search(
		query: query,
		offset: per_page * page,
		limit: per_page,
		order_by: sql.OrderBy{
			column: order_by.str()
			order: sql.Order.descending
		}
	)?

	mut full_packages := []entity.FullPackage{cap: packages.len}
	for _, package in packages {
		full_packages << u.to_full_package(package) ?
	}

	log.info()
		.add('query', query)
		.add('order_by', order_by.str())
		.add('page', page)
		.add('total', total)
		.msg('search results')

	return full_packages, total
}

pub fn (u UseCase) update(package entity.Package) ?entity.Package {
	// TODO: repeat process of create method
	return error('not implemented')
}

