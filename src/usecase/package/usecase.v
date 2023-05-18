module package

import entity
import lib.log
import net.http
import repo

// Used in search and packages view (index page)
pub const per_page = 6

const max_name_len = 35

struct Vcs {
	name       string
	hosts      []string
	protocols  []string
	format_url fn (protocol string, host string, username string) string
}

const allowed_vcs = [
	Vcs{
		name: 'github'
		hosts: ['github.com']
		protocols: ['https', 'http']
		format_url: fn (protocol string, host string, username string) string {
			return '${protocol}://${host}/${username}'
		}
	},
]

pub struct UseCase {
	packages repo.Packages
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

pub fn (u UseCase) get(name string) !entity.Package {
	return u.packages.get(name)
}

pub fn (u UseCase) delete(package_id int, user_id int) ! {
	return u.packages.delete(package_id, user_id)
}

pub fn (u UseCase) query(query string) []entity.Package {
	return u.packages.find_by_query(query)
}

pub fn (u UseCase) find_by_user(user_id int) []entity.Package {
	return u.packages.find_by_user(user_id)
}

pub fn (u UseCase) incr_downloads(name string) ! {
	return u.packages.incr_downloads(name)
}

pub fn (u UseCase) get_recently_updated_packages() []entity.Package {
	return u.packages.get_recently_updated_packages()
}

pub fn (u UseCase) get_packages_count() int {
	return u.packages.get_packages_count()
}

pub fn (u UseCase) get_new_packages() []entity.Package {
	return u.packages.get_new_packages()
}

pub fn (u UseCase) get_most_downloaded_packages() []entity.Package {
	return u.packages.get_most_downloaded_packages()
}

fn check_vcs(url string, username string) !string {
	for vcs in package.allowed_vcs {
		for protocol in vcs.protocols {
			for host in vcs.hosts {
				if !url.starts_with(vcs.format_url(protocol, host, '')) {
					continue
				}

				if !url.starts_with(vcs.format_url(protocol, host, username)) {
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
