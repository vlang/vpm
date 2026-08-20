module package

import entity { Category, Package, User }

// Test helper function: extract_owner_from_url
fn test_extract_owner_from_url_https() {
	assert extract_owner_from_url('https://github.com/v-hono/v-hono-core') == 'v-hono'
	assert extract_owner_from_url('https://github.com/meiseayoung/my-package') == 'meiseayoung'
	assert extract_owner_from_url('https://github.com/vlang/vpm') == 'vlang'
}

fn test_extract_owner_from_url_http() {
	assert extract_owner_from_url('http://github.com/v-hono/v-hono-core') == 'v-hono'
	assert extract_owner_from_url('http://github.com/meiseayoung/my-package') == 'meiseayoung'
}

fn test_extract_owner_from_url_edge_cases() {
	// Empty URL
	assert extract_owner_from_url('') == ''
	// URL without path
	assert extract_owner_from_url('https://github.com/') == ''
	// URL with only owner
	assert extract_owner_from_url('https://github.com/owner') == 'owner'
}

// Test check_vcs function (backward compatibility)
fn test_check_vcs_own_account() {
	// User can publish from their own account
	result := check_vcs('https://github.com/meiseayoung/my-package', 'meiseayoung', false) or {
		assert false, 'should not fail for own account'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_other_account_fails() {
	// User cannot publish from another user's account
	check_vcs('https://github.com/other-user/package', 'meiseayoung', false) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'should fail for other account'
}

fn test_check_vcs_admin_bypass() {
	// Any admin (is_admin: true) can publish from any account.
	result := check_vcs('https://github.com/any-user/package', 'someone', true) or {
		assert false, 'admin should be able to publish from any account'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_non_admin_still_restricted() {
	check_vcs('https://github.com/any-user/package', 'medvednikov', false) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'non-admin must not bypass ownership checks'
}

fn test_check_vcs_unsupported_vcs() {
	// Unsupported VCS should fail
	check_vcs('https://gitlab.com/user/package', 'user', false) or {
		assert err.msg().contains('unsupported')
		return
	}
	assert false, 'should fail for unsupported vcs'
}

// Test check_vcs_with_orgs function (new functionality)
fn test_check_vcs_with_orgs_own_account() {
	// User can still publish from their own account
	result := check_vcs_with_orgs('https://github.com/meiseayoung/my-package', 'meiseayoung', [],
		false) or {
		assert false, 'should not fail for own account'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_with_orgs_member_org() {
	// User can publish from organization they belong to
	user_orgs := ['v-hono', 'another-org']
	result := check_vcs_with_orgs('https://github.com/v-hono/v-hono-core', 'meiseayoung',
		user_orgs, false) or {
		assert false, 'should not fail for member organization: ${err}'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_with_orgs_non_member_org_fails() {
	// User cannot publish from organization they don't belong to
	user_orgs := ['my-org']
	check_vcs_with_orgs('https://github.com/other-org/package', 'meiseayoung', user_orgs, false) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'should fail for non-member organization'
}

fn test_check_vcs_with_orgs_empty_orgs() {
	// With empty orgs list, should behave like check_vcs
	check_vcs_with_orgs('https://github.com/some-org/package', 'meiseayoung', [], false) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'should fail with empty orgs list'
}

fn test_check_vcs_with_orgs_multiple_orgs() {
	// User belongs to multiple organizations
	user_orgs := ['org1', 'org2', 'v-hono', 'org3']

	// Can publish from any of them
	result1 := check_vcs_with_orgs('https://github.com/org1/package', 'user', user_orgs, false) or {
		assert false, 'should work for org1'
		return
	}
	assert result1 == 'github'

	result2 := check_vcs_with_orgs('https://github.com/v-hono/package', 'user', user_orgs, false) or {
		assert false, 'should work for v-hono'
		return
	}
	assert result2 == 'github'
}

fn test_check_vcs_with_orgs_org_prefix_bypass() {
	user_orgs := ['acme']
	check_vcs_with_orgs('https://github.com/acme-inc/some-repository', 'someone', user_orgs, false) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'membership in acme must not authorize acme-inc'
}

fn test_check_vcs_with_orgs_account_prefix_bypass() {
	check_vcs_with_orgs('https://github.com/meiseayoung-clone/repo', 'meiseayoung', [], false) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'own-account prefix match must not authorize a different account'
}

fn test_check_vcs_with_orgs_case_insensitive() {
	result := check_vcs_with_orgs('https://github.com/Acme/repo', 'someone', ['acme'], false) or {
		assert false, 'organization match should be case-insensitive: ${err}'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_with_orgs_http_protocol() {
	// Should work with http protocol too
	user_orgs := ['v-hono']
	result := check_vcs_with_orgs('http://github.com/v-hono/package', 'meiseayoung', user_orgs,
		false) or {
		assert false, 'should work with http protocol'
		return
	}
	assert result == 'github'
}

fn test_resolve_owner_prefix_own_account() {
	assert resolve_owner_prefix('https://github.com/meiseayoung/pkg', 'meiseayoung', []) == 'meiseayoung'
}

fn test_resolve_owner_prefix_member_org() {
	prefix := resolve_owner_prefix('https://github.com/v-hono/pkg', 'meiseayoung', [
		'v-hono',
		'other',
	])
	assert prefix == 'v-hono'
}

fn test_resolve_owner_prefix_falls_back_to_username() {
	// If the URL's owner isn't the user's own account or a known
	// organization, fall back to the user's own namespace rather than
	// letting an arbitrary owner segment become the package prefix.
	prefix := resolve_owner_prefix('https://github.com/some-other-org/pkg', 'meiseayoung', [
		'v-hono',
	])
	assert prefix == 'meiseayoung'
}

fn test_resolve_owner_prefix_bypass() {
	prefix := resolve_owner_prefix('https://github.com/acme-inc/pkg', 'someone', [
		'acme',
	])
	assert prefix == 'someone'
}

fn test_resolve_owner_prefix_case_insensitive() {
	prefix := resolve_owner_prefix('https://github.com/Acme/pkg', 'someone', ['acme'])
	assert prefix == 'acme'
}

fn test_resolve_package_prefix_admin_uses_url_owner() {
	prefix := resolve_package_prefix('https://github.com/acme/pkg', 'admin', []string{}, true)
	assert prefix == 'acme'
}

fn test_resolve_package_prefix_non_admin_unknown_owner_falls_back_to_username() {
	prefix := resolve_package_prefix('https://github.com/acme/pkg', 'someone', []string{}, false)
	assert prefix == 'someone'
}

// Test is_valid_mod_name function
fn test_is_valid_mod_name_valid() {
	assert is_valid_mod_name('hono') == true
	assert is_valid_mod_name('my.package') == true
	assert is_valid_mod_name('Package123') == true
	assert is_valid_mod_name('ab') == true // minimum length
}

fn test_is_valid_mod_name_invalid() {
	assert is_valid_mod_name('a') == false // too short
	assert is_valid_mod_name('') == false // empty
	assert is_valid_mod_name('my-package') == false // contains hyphen
	assert is_valid_mod_name('my_package') == false // contains underscore
	assert is_valid_mod_name('my package') == false // contains space
	assert is_valid_mod_name('@scope/package') == false // contains @ and /
}

fn test_is_valid_mod_name_max_length() {
	// max_name_len is 35
	valid_name := 'a'.repeat(35)
	assert is_valid_mod_name(valid_name) == true

	invalid_name := 'a'.repeat(36)
	assert is_valid_mod_name(invalid_name) == false
}

fn test_extract_repo_name_from_url() {
	assert extract_repo_name_from_url('https://github.com/v-hono/v-hono-core') == 'v-hono-core'
	assert extract_repo_name_from_url('https://github.com/vlang/vpm.git') == 'vpm'
	assert extract_repo_name_from_url('https://github.com/vlang/vpm/') == 'vpm'
	assert extract_repo_name_from_url('https://github.com/vlang/vpm/issues/1') == 'vpm'
	assert extract_repo_name_from_url('https://github.com/owner') == ''
	assert extract_repo_name_from_url('') == ''
}

fn test_parse_repo_url_accepts_known_host() {
	parsed := parse_repo_url('https://github.com/v-hono/v-hono-core') or {
		assert false, 'should accept a github.com URL: ${err}'
		return
	}
	assert parsed.vcs_name == 'github'
	assert parsed.owner == 'v-hono'
	assert parsed.repo_name == 'v-hono-core'
}

fn test_parse_repo_url_rejects_unknown_host() {
	parse_repo_url('https://gitlab.com/owner/repo') or {
		assert err.msg().contains('unsupported')
		return
	}
	assert false, 'should reject a host not in allowed_vcs'
}

fn test_own_account_skips_repo_access_check() {
	require_repo_write_access('https://github.com/meiseayoung/pkg', 'meiseayoung', 'meiseayoung',
		'', false) or {
		assert false, 'should not check permissions for own-account submissions: ${err}'
		return
	}
}

fn test_repo_access_fails_without_token() {
	require_repo_write_access('https://github.com/acme/pkg', 'someone', 'acme', '', false) or {
		assert err.msg().contains('push access')
		return
	}
	assert false, 'org-prefixed submission with no token must not be authorized'
}

fn test_require_repo_write_access_skips_check_for_admin() {
	require_repo_write_access('https://github.com/acme/pkg', 'admin', 'acme', '', true) or {
		assert false, 'admin create should bypass the live GitHub repo-access check: ${err}'
		return
	}
}

fn test_flattened_personal_package_skips_access_check() {
	require_repo_write_access('https://github.com/meiseayoung/ui', 'meiseayoung', 'ui', '', false) or {
		assert false, 'a flattened personal package must not require a live GitHub check: ${err}'
		return
	}
}

fn test_package_prefix() {
	assert package_prefix('v-hono.hono') == 'v-hono'
	assert package_prefix('meiseayoung.mypkg') == 'meiseayoung'
	assert package_prefix('noprefix') == 'noprefix'
	assert package_prefix('') == ''
}

// Minimal fakes for UseCase.delete()'s dependencies. delete_calls/get_by_id_pkg
// are pointers so a value receiver method can still record what happened
// for the test to observe.
struct FakeCategoriesRepoForDelete {}

fn (r FakeCategoriesRepoForDelete) add_category_to_package(category_id int, package_id int) ! {}

fn (r FakeCategoriesRepoForDelete) get(slug string) !Category {
	return error('not found')
}

fn (r FakeCategoriesRepoForDelete) get_all() ![]Category {
	return []Category{}
}

fn (r FakeCategoriesRepoForDelete) get_category_packages(category_id int) ![]Package {
	return []Package{}
}

fn (r FakeCategoriesRepoForDelete) get_package_categories(package_id int) ![]Category {
	return []Category{}
}

fn (r FakeCategoriesRepoForDelete) update_category_stats(category_id int) ! {}

struct FakeOrganizationsRepoForDelete {}

fn (r FakeOrganizationsRepoForDelete) get_user_org_names(user_id int) []string {
	return []string{}
}

struct FakeUsersRepoForDelete {
	owner User
}

fn (r FakeUsersRepoForDelete) get_by_id(id int) ?User {
	return r.owner
}

struct FakePackagesRepoForDelete {
	pkg                 Package
	delete_calls        &int
	last_delete_user_id &int = unsafe { nil }
}

fn (r FakePackagesRepoForDelete) all() []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) get(name string) !Package {
	return error('not found')
}

fn (r FakePackagesRepoForDelete) get_by_id(id int) !Package {
	return r.pkg
}

fn (r FakePackagesRepoForDelete) find_by_query(query string) []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) find_by_url(url string) []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) find_by_user(user_id int) []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) count_by_user(user_id int) int {
	return 0
}

fn (r FakePackagesRepoForDelete) incr_downloads(name string) ! {}

fn (r FakePackagesRepoForDelete) create_package(package Package) ! {}

fn (r FakePackagesRepoForDelete) delete(package_id int, user_id int) ! {
	p := r.delete_calls
	unsafe {
		*p = *p + 1
	}
	if !isnil(r.last_delete_user_id) {
		q := r.last_delete_user_id
		unsafe {
			*q = user_id
		}
	}
}

fn (r FakePackagesRepoForDelete) get_recently_updated_packages() []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) get_packages_count() int {
	return 0
}

fn (r FakePackagesRepoForDelete) get_new_packages() []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) get_most_downloaded_packages() []Package {
	return []Package{}
}

fn (r FakePackagesRepoForDelete) update_package_stars(package_id int, stars int) ! {}

fn (r FakePackagesRepoForDelete) update_package_info(package_id int, name string, url string, description string) ! {
}

// Deleting an organization package requires current repository access.
// If access can no longer be verified, the package must remain untouched.
fn test_delete_rejects_lost_org_access() {
	mut delete_calls := 0
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:          Package{
				id:      1
				name:    'acme.somelib'
				url:     'https://github.com/acme/somelib'
				user_id: 42
			}
			delete_calls: &delete_calls
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(1, 42, false) or {
		assert err.msg().contains('push access')
		assert delete_calls == 0
		return
	}
	assert false, 'delete of an org package must fail once the owner has no verifiable access'
}

// Personal package deletion does not require an organization access check.
fn test_delete_allows_personal_package() {
	mut delete_calls := 0
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:          Package{
				id:      2
				name:    'someone.somelib'
				url:     'https://github.com/someone/somelib'
				user_id: 42
			}
			delete_calls: &delete_calls
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(2, 42, false) or {
		assert false, 'personal package delete should not require an org/repo check: ${err}'
		return
	}
	assert delete_calls == 1
}

fn test_delete_allows_legacy_non_github_package() {
	mut delete_calls := 0
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:          Package{
				id:      6
				name:    'someone.legacy'
				url:     'https://example.com/someone/legacy'
				user_id: 42
			}
			delete_calls: &delete_calls
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(6, 42, false) or {
		assert false, 'owner should be able to delete a legacy unsupported URL: ${err}'
		return
	}
	assert delete_calls == 1
}

fn test_delete_allows_legacy_owner_prefixed_package() {
	mut delete_calls := 0
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:          Package{
				id:      7
				name:    'someone.legacy'
				url:     'https://github.com/acme/legacy'
				user_id: 42
			}
			delete_calls: &delete_calls
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(7, 42, false) or {
		assert false, 'owner should be able to delete legacy personal-prefix third-party GitHub package: ${err}'
		return
	}
	assert delete_calls == 1
}

// is_admin bypasses the org/repo check entirely.
fn test_delete_admin_bypasses_org_check() {
	mut delete_calls := 0
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:          Package{
				id:      3
				name:    'acme.somelib'
				url:     'https://github.com/acme/somelib'
				user_id: 42
			}
			delete_calls: &delete_calls
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(3, 42, true) or {
		assert false, 'admin delete should bypass the org/repo check: ${err}'
		return
	}
	assert delete_calls == 1
}

// Admin deletion must target the package's actual owner.
fn test_admin_delete_uses_package_owner() {
	mut delete_calls := 0
	mut last_delete_user_id := -1
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:                 Package{
				id:      5
				name:    'acme.somelib'
				url:     'https://github.com/acme/somelib'
				user_id: 42
			}
			delete_calls:        &delete_calls
			last_delete_user_id: &last_delete_user_id
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(5, 7, true) or {
		assert false, 'admin delete should succeed regardless of who owns the package: ${err}'
		return
	}
	assert delete_calls == 1
	assert last_delete_user_id == 42
}

// Reject non-owners before performing any repository access check.
fn test_delete_rejects_non_owner_before_repo_check() {
	mut delete_calls := 0
	u := UseCase{
		categories:    FakeCategoriesRepoForDelete{}
		packages:      FakePackagesRepoForDelete{
			pkg:          Package{
				id:      4
				name:    'acme.somelib'
				url:     'https://github.com/acme/somelib'
				user_id: 42
			}
			delete_calls: &delete_calls
		}
		users:         FakeUsersRepoForDelete{
			owner: User{
				id:           42
				username:     'someone'
				github_token: ''
			}
		}
		organizations: FakeOrganizationsRepoForDelete{}
	}

	u.delete(4, 99, false) or {
		assert err.msg().contains('permission')
		assert !err.msg().contains('push access')
		assert delete_calls == 0
		return
	}
	assert false, 'a non-owner caller must not be able to delete this package'
}
