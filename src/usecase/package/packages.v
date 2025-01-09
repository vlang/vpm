module package

import entity { Package, User }
import lib.log
import net.http
import net.urllib
import x.json2

// Used in search and packages view (index page)
pub const per_page = 6

const max_name_len = 35
const max_package_url_len = 75

fn default_url_formatter(protocol string, host string, username string) string {
	return '${protocol}://${host}/${username}'
}

struct Vcs {
	name       string
	hosts      []string
	protocols  []string
	format_url fn (protocol string, host string, username string) string = default_url_formatter
}

const allowed_vcs = [
	Vcs{
		name:       'github'
		hosts:      ['github.com']
		protocols:  ['https', 'http']
		format_url: default_url_formatter
	},
]

pub interface PackagesRepo {
	all() []Package
	get(name string) !Package
	get_by_id(id int) !Package
	find_by_query(query string) []Package
	find_by_url(url string) []Package
	find_by_user(user_id int) []Package
	count_by_user(user_id int) int
	incr_downloads(name string) !
	create_package(package Package) !
	delete(package_id int, user_id int) !
	get_recently_updated_packages() []Package
	get_packages_count() int
	get_new_packages() []Package
	get_most_downloaded_packages() []Package
	update_package_stars(package_id int, stars int) !
	update_package_info(package_id int, name string, url string, description string) !
}

pub interface UsersRepo {
	get_by_id(id int) ?User
}

pub fn (u UseCase) create(name string, vcsUrl string, description string, user User) ! {
	name_lower := name.to_lower()
	log.info().add('name', name).msg('create package')
	if user.username == '' || !is_valid_mod_name(name_lower) {
		return error('not valid mod name cur_user="${user.username}"')
	}

	url := vcsUrl.replace('<', '&lt;').limit(max_package_url_len)
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

	u.packages.create_package(Package{
		name:        user.username + '.' + name.limit(max_name_len)
		url:         url
		description: description
		vcs:         vcs_name.limit(3)
		user_id:     user.id
	}) or { return err }

	return
}

pub fn (u UseCase) get(name string) !Package {
	mut pkg := u.packages.get(name)!
	pkg.author = u.users.get_by_id(pkg.user_id) or { return error("package author doesn't exist") }
	return pkg
}

pub fn (u UseCase) delete(package_id int, user_id int) ! {
	return u.packages.delete(package_id, user_id)
}

pub fn (u UseCase) query(query string, sort string) []Package {
	mut pkgs := u.packages.find_by_query(query)
	package_sort := PackageSort.new(sort)
	pkgs.sort_with_compare(package_sort.compare)
	return pkgs
}

pub fn (u UseCase) find_by_user(user_id int) []Package {
	return u.packages.find_by_user(user_id)
}

pub fn (u UseCase) incr_downloads(name string) ! {
	return u.packages.incr_downloads(name)
}

pub fn (u UseCase) get_recently_updated_packages() []Package {
	return u.packages.get_recently_updated_packages()
}

pub fn (u UseCase) get_packages_count() int {
	return u.packages.get_packages_count()
}

pub fn (u UseCase) get_new_packages() []Package {
	return u.packages.get_new_packages()
}

pub fn (u UseCase) get_most_downloaded_packages() []Package {
	return u.packages.get_most_downloaded_packages()
}

pub fn (u UseCase) update_package_stats(package_id int) ! {
	pkg := u.packages.get_by_id(package_id)!
	url := urllib.parse(pkg.url)!

	// Getting default git branch
	bb := 'https://api.github.com/repos${url.path}'
	api_repo := http.get(bb)!
	if api_repo.status() != http.Status.ok {
		return error('repo status is not 200, real ${api_repo.status()}')
	}

	// Updatin stars
	body := json2.raw_decode(api_repo.body)!
	any_stars := body.as_map()['stargazers_count'] or { json2.Any(0) }
	u.packages.update_package_stars(pkg.id, any_stars.int())!
}

pub fn (u UseCase) update_package_info(package_id int, name string, url string, description string) ! {
	name_lower := name.to_lower()
	if !is_valid_mod_name(name_lower) {
		return error('not valid mod name')
	}

	pkg := u.packages.get_by_id(package_id)!
	usr := u.users.get_by_id(pkg.user_id) or {
		return error('package ${package_id} user_id is not valid')
	}

	repo_url := url.replace('<', '&lt;').limit(max_package_url_len)
	check_vcs(repo_url, usr.username)!

	resp := http.get(repo_url) or { return error('Failed to fetch package URL') }
	if resp.status_code == 404 {
		return error('This package URL does not exist (404)')
	}

	if u.packages.count_by_user(usr.id) > 100 {
		return error('One user can submit no more than 100 packages')
	}

	// Make sure the URL is unique
	if pkg.url != repo_url {
		existing := u.packages.find_by_url(repo_url)
		if existing.len > 0 {
			return error('This URL has already been submitted')
		}
	}

	u.packages.update_package_info(package_id, usr.username + '.' + name.limit(max_name_len),
		repo_url, description)!
}

pub fn check_vcs(url string, username string) !string {
	for vcs in allowed_vcs {
		for protocol in vcs.protocols {
			for host in vcs.hosts {
				if !url.starts_with(vcs.format_url(protocol, host, '')) {
					continue
				}

				if !url.starts_with(vcs.format_url(protocol, host, username))
					&& username != 'medvednikov' {
					return error('You must submit a package from your own account')
				}

				return vcs.name
			}
		}
	}

	return error('unsupported vcs')
}

pub fn is_valid_mod_name(s string) bool {
	if s.len > max_name_len || s.len < 2 {
		return false
	}
	for c in s {
		if !(c >= `A` && c <= `Z`) && !(c >= `a` && c <= `z`) && !(c >= `0` && c <= `9`) && c != `.` {
			return false
		}
	}
	return true
}
