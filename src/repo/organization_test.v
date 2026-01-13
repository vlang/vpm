module repo

import entity { UserOrganization }

// Mock database for testing
struct MockOrmConnection {
mut:
	orgs []UserOrganization
}

// Test UserOrganization entity
fn test_user_organization_creation() {
	org := UserOrganization{
		id:       1
		user_id:  100
		org_name: 'v-hono'
	}

	assert org.id == 1
	assert org.user_id == 100
	assert org.org_name == 'v-hono'
}

fn test_user_organization_multiple() {
	orgs := [
		UserOrganization{
			id:       1
			user_id:  100
			org_name: 'v-hono'
		},
		UserOrganization{
			id:       2
			user_id:  100
			org_name: 'vlang'
		},
		UserOrganization{
			id:       3
			user_id:  100
			org_name: 'another-org'
		},
	]

	assert orgs.len == 3
	assert orgs[0].org_name == 'v-hono'
	assert orgs[1].org_name == 'vlang'
	assert orgs[2].org_name == 'another-org'
}

// Test helper function to extract org names
fn test_extract_org_names() {
	orgs := [
		UserOrganization{
			id:       1
			user_id:  100
			org_name: 'v-hono'
		},
		UserOrganization{
			id:       2
			user_id:  100
			org_name: 'vlang'
		},
	]

	mut names := []string{cap: orgs.len}
	for org in orgs {
		names << org.org_name
	}

	assert names.len == 2
	assert 'v-hono' in names
	assert 'vlang' in names
}

// Test user belongs to org logic
fn check_membership(orgs []UserOrganization, org_name string) bool {
	for org in orgs {
		if org.org_name == org_name {
			return true
		}
	}
	return false
}

fn test_user_belongs_to_org_logic() {
	orgs := [
		UserOrganization{
			id:       1
			user_id:  100
			org_name: 'v-hono'
		},
		UserOrganization{
			id:       2
			user_id:  100
			org_name: 'vlang'
		},
	]

	assert check_membership(orgs, 'v-hono') == true
	assert check_membership(orgs, 'vlang') == true
	assert check_membership(orgs, 'other-org') == false
}
