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

pub interface OrganizationsRepo {
	get_user_org_names(user_id int) []string
}

// Extract owner from GitHub URL (e.g., "https://github.com/v-hono/repo" -> "v-hono")
// Not meant to be called on its own outside parse_repo_url.
fn extract_owner_from_url(url string) string {
	// Remove protocol
	mut path := url.replace('https://', '').replace('http://', '')
	// Remove host
	if path.starts_with('github.com/') {
		path = path.replace('github.com/', '')
	}
	// Get first path segment (owner)
	parts := path.split('/')
	if parts.len > 0 {
		return parts[0]
	}
	return ''
}

fn extract_repo_name_from_url(url string) string {
	mut path := url.replace('https://', '').replace('http://', '')
	if path.starts_with('github.com/') {
		path = path.replace('github.com/', '')
	}
	parts := path.split('/')
	if parts.len < 2 {
		return ''
	}
	mut name := parts[1].all_before('?').all_before('#')
	if name.ends_with('.git') {
		name = name[..name.len - 4]
	}
	return name
}

// ParsedRepoUrl is an (owner, repo) pair that has been confirmed to come
// from a URL matching one of allowed_vcs's configured hosts/protocols.
struct ParsedRepoUrl {
	vcs_name  string
	owner     string
	repo_name string
}

fn parse_repo_url(url string) !ParsedRepoUrl {
	for vcs in allowed_vcs {
		for protocol in vcs.protocols {
			for host in vcs.hosts {
				if !url.starts_with(vcs.format_url(protocol, host, '')) {
					continue
				}
				return ParsedRepoUrl{
					vcs_name:  vcs.name
					owner:     extract_owner_from_url(url)
					repo_name: extract_repo_name_from_url(url)
				}
			}
		}
	}
	return error('unsupported vcs')
}

fn resolve_owner_prefix(url string, username string, user_orgs []string) string {
	parsed := parse_repo_url(url) or { return username }
	owner := parsed.owner.to_lower()
	if owner == username.to_lower() {
		return username
	}
	for org in user_orgs {
		if owner == org.to_lower() {
			return org
		}
	}
	return username
}

fn resolve_package_prefix(url string, username string, user_orgs []string, is_admin bool) string {
	if is_admin {
		parsed := parse_repo_url(url) or { return username }
		if parsed.owner != '' {
			return parsed.owner
		}
	}
	return resolve_owner_prefix(url, username, user_orgs)
}

fn user_has_repo_write_access(token string, owner string, repo_name string) bool {
	if token == '' || owner == '' || repo_name == '' {
		return false
	}
	resp := http.fetch(
		url:    'https://api.github.com/repos/${owner}/${repo_name}'
		method: .get
		header: http.new_header(key: .authorization, value: 'token ${token}')
	) or { return false }
	if resp.status_code != 200 {
		return false
	}
	body := json2.decode[json2.Any](resp.body) or { return false }
	permissions := body.as_map()['permissions'] or { return false }
	perms_map := permissions.as_map()
	push := perms_map['push'] or { json2.Any(false) }
	admin := perms_map['admin'] or { json2.Any(false) }
	return push.bool() || admin.bool()
}

// Require live repository write access for organization owned packages.
// Personal repositories and admin operations bypass this check.
//
// Use the URL owner for this decision because flattened package names don't
// preserve the owner's username in their prefix.
fn require_repo_write_access(url string, username string, pkg_prefix string, github_token string, is_admin bool) ! {
	if is_admin {
		return
	}
	parsed := parse_repo_url(url)!
	if parsed.owner.to_lower() == username.to_lower() {
		return
	}
	if !user_has_repo_write_access(github_token, parsed.owner, parsed.repo_name) {
		return error('You do not have push access to this repository in ${pkg_prefix}')
	}
}

pub fn (u UseCase) create(name string, vcsUrl string, description string, user User) ! {
	user_orgs := u.organizations.get_user_org_names(user.id)
	return u.create_with_orgs(name, vcsUrl, description, user, user_orgs)
}

pub fn (u UseCase) create_with_orgs(name string, vcsUrl string, description string, user User, user_orgs []string) ! {
	name_lower := name.to_lower()
	log.info().add('name', name).msg('create package')
	if user.username == '' || !is_valid_mod_name(name_lower) {
		return error('not valid mod name cur_user="${user.username}"')
	}

	url := vcsUrl.replace('<', '&lt;').limit(max_package_url_len)
	log.info().add('url', name).msg('create package')

	vcs_name := check_vcs_with_orgs(url, user.username, user_orgs, user.is_admin) or { return err }

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

	// Determine package name prefix (user or organization)
	pkg_prefix := resolve_package_prefix(url, user.username, user_orgs, user.is_admin)
	require_repo_write_access(url, user.username, pkg_prefix, user.github_token, user.is_admin) or {
		return err
	}

	u.packages.create_package(Package{
		name:        pkg_prefix + '.' + name.limit(max_name_len)
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

// Return the namespace before the first dot in a stored package name.
fn package_prefix(pkg_name string) string {
	parts := pkg_name.split('.')
	if parts.len == 0 {
		return ''
	}
	return parts[0]
}

fn stored_package_requires_repo_write_access(pkg Package, username string) bool {
	parsed := parse_repo_url(pkg.url) or { return false }
	if parsed.owner.to_lower() == username.to_lower() {
		return false
	}
	return package_prefix(pkg.name).to_lower() == parsed.owner.to_lower()
}

// Delete a package after verifying ownership and for organization packages,
// current repository write access. Admins bypass these checks.
//
// The repository delete must use the package's recorded owner ID because its
// query is scoped by both package ID and user ID.
pub fn (u UseCase) delete(package_id int, user_id int, is_admin bool) ! {
	pkg := u.packages.get_by_id(package_id)!
	if !is_admin {
		if pkg.user_id != user_id {
			return error('you do not have permission to delete this package')
		}
		owner := u.users.get_by_id(pkg.user_id) or {
			return error('package ${package_id} user_id is not valid')
		}
		if stored_package_requires_repo_write_access(pkg, owner.username) {
			require_repo_write_access(pkg.url, owner.username, package_prefix(pkg.name),
				owner.github_token, false) or { return err }
		}
	}
	return u.packages.delete(package_id, pkg.user_id)
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
	body := json2.decode[json2.Any](api_repo.body)!
	any_stars := body.as_map()['stargazers_count'] or { json2.Any(0) }
	u.packages.update_package_stars(pkg.id, any_stars.int())!
}

pub fn (u UseCase) update_package_info(package_id int, name string, url string, description string, caller_is_admin bool) ! {
	name_lower := name.to_lower()
	if !is_valid_mod_name(name_lower) {
		return error('not valid mod name')
	}

	pkg := u.packages.get_by_id(package_id)!
	usr := u.users.get_by_id(pkg.user_id) or {
		return error('package ${package_id} user_id is not valid')
	}

	repo_url := url.replace('<', '&lt;').limit(max_package_url_len)
	user_orgs := u.organizations.get_user_org_names(usr.id)
	check_vcs_with_orgs(repo_url, usr.username, user_orgs, usr.is_admin || caller_is_admin) or {
		return err
	}

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

	// Preserve the repository owner as the package prefix during admin edits.
	// Unlike cached organization membership, the URL owner reflects the stored package namespace directly.
	pkg_prefix := if caller_is_admin {
		parse_repo_url(repo_url) or {
			ParsedRepoUrl{
				owner: package_prefix(pkg.name)
			}
		}.owner
	} else {
		resolve_owner_prefix(repo_url, usr.username, user_orgs)
	}
	if !caller_is_admin {
		require_repo_write_access(repo_url, usr.username, pkg_prefix, usr.github_token, false) or {
			return err
		}
	}
	u.packages.update_package_info(package_id, pkg_prefix + '.' + name.limit(max_name_len),
		repo_url, description)!
}

pub fn check_vcs(url string, username string, is_admin bool) !string {
	return check_vcs_with_orgs(url, username, [], is_admin)
}

pub fn check_vcs_with_orgs(url string, username string, user_orgs []string, is_admin bool) !string {
	parsed := parse_repo_url(url)!
	owner := parsed.owner.to_lower()
	username_lower := username.to_lower()

	// Check if URL belongs to user's account
	if owner == username_lower {
		return parsed.vcs_name
	}

	// Check if URL belongs to one of user's organizations
	for org in user_orgs {
		if owner == org.to_lower() {
			return parsed.vcs_name
		}
	}

	if is_admin {
		return parsed.vcs_name
	}

	return error('You must submit a package from your own account or an organization you belong to')
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
