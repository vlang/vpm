module package

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
	result := check_vcs('https://github.com/meiseayoung/my-package', 'meiseayoung') or {
		assert false, 'should not fail for own account'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_other_account_fails() {
	// User cannot publish from another user's account
	check_vcs('https://github.com/other-user/package', 'meiseayoung') or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'should fail for other account'
}

fn test_check_vcs_admin_bypass() {
	// Admin (medvednikov) can publish from any account
	result := check_vcs('https://github.com/any-user/package', 'medvednikov') or {
		assert false, 'admin should be able to publish from any account'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_unsupported_vcs() {
	// Unsupported VCS should fail
	check_vcs('https://gitlab.com/user/package', 'user') or {
		assert err.msg().contains('unsupported')
		return
	}
	assert false, 'should fail for unsupported vcs'
}

// Test check_vcs_with_orgs function (new functionality)
fn test_check_vcs_with_orgs_own_account() {
	// User can still publish from their own account
	result := check_vcs_with_orgs('https://github.com/meiseayoung/my-package', 'meiseayoung', []) or {
		assert false, 'should not fail for own account'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_with_orgs_member_org() {
	// User can publish from organization they belong to
	user_orgs := ['v-hono', 'another-org']
	result := check_vcs_with_orgs('https://github.com/v-hono/v-hono-core', 'meiseayoung', user_orgs) or {
		assert false, 'should not fail for member organization: ${err}'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_with_orgs_non_member_org_fails() {
	// User cannot publish from organization they don't belong to
	user_orgs := ['my-org']
	check_vcs_with_orgs('https://github.com/other-org/package', 'meiseayoung', user_orgs) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'should fail for non-member organization'
}

fn test_check_vcs_with_orgs_empty_orgs() {
	// With empty orgs list, should behave like check_vcs
	check_vcs_with_orgs('https://github.com/some-org/package', 'meiseayoung', []) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'should fail with empty orgs list'
}

fn test_check_vcs_with_orgs_multiple_orgs() {
	// User belongs to multiple organizations
	user_orgs := ['org1', 'org2', 'v-hono', 'org3']

	// Can publish from any of them
	result1 := check_vcs_with_orgs('https://github.com/org1/package', 'user', user_orgs) or {
		assert false, 'should work for org1'
		return
	}
	assert result1 == 'github'

	result2 := check_vcs_with_orgs('https://github.com/v-hono/package', 'user', user_orgs) or {
		assert false, 'should work for v-hono'
		return
	}
	assert result2 == 'github'
}

fn test_check_vcs_with_orgs_org_prefix_bypass() {
	user_orgs := ['acme']
	check_vcs_with_orgs('https://github.com/acme-inc/some-repository', 'someone', user_orgs) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'membership in acme must not authorize acme-inc'
}

fn test_check_vcs_with_orgs_account_prefix_bypass() {
	check_vcs_with_orgs('https://github.com/meiseayoung-clone/repo', 'meiseayoung', []) or {
		assert err.msg().contains('own account') || err.msg().contains('organization')
		return
	}
	assert false, 'own-account prefix match must not authorize a different account'
}

fn test_check_vcs_with_orgs_case_insensitive() {
	result := check_vcs_with_orgs('https://github.com/Acme/repo', 'someone', ['acme']) or {
		assert false, 'organization match should be case-insensitive: ${err}'
		return
	}
	assert result == 'github'
}

fn test_check_vcs_with_orgs_http_protocol() {
	// Should work with http protocol too
	user_orgs := ['v-hono']
	result := check_vcs_with_orgs('http://github.com/v-hono/package', 'meiseayoung', user_orgs) or {
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
