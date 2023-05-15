module package

import entity
import lib.log
import net.http
import repo
import usecase.user
import vweb

// Used in search and packages view (index page)
pub const per_page = 6

const max_name_len = 35

struct Vcs {
	name       string
	hosts      []string
	protocols  []string
	url_format string
}

const allowed_vcs = [
	Vcs{
		name: 'github'
		hosts: ['github.com']
		protocols: ['https', 'http']
		url_format: '%HOST%/%USER%/%NAME%'
	},
]

pub struct UseCase {
	packages repo.Packages
}

pub fn new_use_case(packages repo.Packages) UseCase {
	return UseCase{
		packages: packages
	}
}

pub fn (u UseCase) create(name string, vcsUrl string, description string, user entity.User) ! {
	name_lower := name.to_lower()
	log.info().add('name', name).msg('create package')
	if user.username == '' || !is_valid_mod_name(name_lower) {
		return error('not valid mod name cur_user="${user.username}"')
	}

	url := vcsUrl.replace('<', '&lt;').limit(50)
	log.info().add('url', name).msg('create package')

	vcs_name := check_vcs(url, user.username) or { return err }

	resp := http.get(url) or { return error('Failed to fetch package URL') }
	if resp.status_code == 404 {
		return error('This package URL does not exist (404)')
	}

	if u.packages.count_by_user(user.id) > 100 {
		return error('One user can submit no more than 100 packages')
	}

	// Make sure the URL is unique
	existing := u.packages.find_by_url(url)
	if existing.len > 0 {
		return error('This URL has already been submitted')
	}

	u.packages.create_package(entity.Package{
		name: user.username + '.' + name.limit(package.max_name_len)
		url: url
		description: description
		vcs: vcs_name.limit(3)
		user_id: user.id
	}) or { return err }

	return
}

pub fn (u UseCase) delete(package_id int, user entity.User) ! {
	return u.packages.delete(package_id, user.id)
}

pub fn (u UseCase) query(query string) []entity.Package {
	return u.packages.find_by_query(query)
}

pub fn (u UseCase) find_by_user(user_id int) []entity.Package {
	return u.packages.find_by_user(user_id)
}

fn check_vcs(url string, username string) !string {
	for vcs in package.allowed_vcs {
		for protocol in vcs.protocols {
			for host in vcs.hosts {
				if !url.starts_with('${protocol}://${host}/') {
					continue
				}

				if !url.starts_with('${protocol}://${host}/${username}') {
					return error('you must submit a package from your own account')
				}

				return vcs.name
			}
		}
	}

	return error('unsupported vcs')
}

fn is_valid_mod_name(s string) bool {
	if s.len > package.max_name_len || s.len < 2 {
		return false
	}
	for c in s {
		if !(c >= `A` && c <= `Z`) && !(c >= `a` && c <= `z`) && !(c >= `0` && c <= `9`) && c != `.` {
			return false
		}
	}
	return true
}

//
// pub fn (u UseCase) categories() ?[]entity.Category {
// 	categories := u.category.get_all()?
//
// 	log.info()
// 		.add('count', categories.len)
// 		.msg('all categories')
//
// 	return categories
// }
//
// pub fn (u UseCase) category(slug string, order_by OrderBy, page int) ?([]entity.FullPackage, int) {
// 	category := u.category.get_by_slug(slug)?
// 	// TODO: paginate
// 	packages := u.package.get_by_category_id(category.id)?
//
// 	offset := page * package.per_page
// 	mut full_packages := []entity.FullPackage{cap: package.per_page}
// 	for _, package in packages[offset..offset + package.per_page] {
// 		full_packages << u.to_full_package(package)?
// 	}
//
// 	log.info()
// 		.add('slug', slug)
// 		.add('order_by', order_by.str())
// 		.add('page', page)
// 		.add('count', packages.len)
// 		.msg('packages with category')
//
// 	return full_packages, packages.len
// }
//
// pub fn (u UseCase) get_by_author(author_id int) ?[]entity.FullPackage {
// 	packages := u.package.get_by_author(author_id)?
//
// 	mut full_packages := []entity.FullPackage{cap: packages.len}
// 	for _, package in packages {
// 		full_packages << u.to_full_package(package)?
// 	}
//
// 	log.info()
// 		.add('author', author_id)
// 		.add('count', packages.len)
// 		.msg('packages by author')
//
// 	return full_packages
// }
//
// pub fn (u UseCase) old_package(username string, package string) ?entity.OldPackage {
// 	usr := u.user.get_by_username(username)?
// 	pkg := u.package.get(usr.id, package)?
// 	name := if pkg.is_flatten { pkg.name } else { '${usr.username}.${pkg.name}' }
//
// 	log.info()
// 		.add('author', usr.id)
// 		.add('package', pkg.id)
// 		.add('is_flatten', pkg.is_flatten)
// 		.add('name', name)
// 		.msg('old package')
//
// 	return entity.OldPackage{
// 		id: pkg.id
// 		name: name
// 		vcs: pkg.vcs
// 		url: pkg.url
// 		nr_downloads: pkg.downloads
// 	}
// }
//
// pub fn (u UseCase) full_package(username string, package string) ?entity.FullPackage {
// 	usr := u.user.get_by_username(username)?
// 	pkg := u.package.get(usr.id, package)?
//
// 	log.info()
// 		.add('author', usr.id)
// 		.add('package', pkg.id)
// 		.add('is_flatten', pkg.is_flatten)
// 		.msg('full package')
//
// 	return u.to_full_package(pkg)
// }
//
// pub fn (u UseCase) packages_view() ?entity.PackagesView {
// 	return error('not implemented')
// }
//
// pub fn (u UseCase) search(query string, category string, order_by OrderBy, page int) ?([]entity.FullPackage, int) {
// 	mut full_packages := []entity.FullPackage{}
// 	total := 0
// 	return full_packages, total
// }
//
// pub fn (u UseCase) update(package entity.Package) ?entity.Package {
// 	// TODO: repeat process of create method
// 	return error('not implemented')
// }
//
// fn (u UseCase) to_full_package(package entity.Package) ?entity.FullPackage {
// 	author := u.user.get(package.author_id)?
// 	categories := u.category.get_by_package_id(package.id)?
//
// 	return entity.FullPackage{
// 		Package: package
// 		author: author
// 		categories: categories
// 	}
// }
