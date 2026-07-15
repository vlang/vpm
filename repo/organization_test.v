module repo

import entity { UserOrganization }
import db.pg
import rand

// Create an isolated disposable database for destructive integration tests.
// The returned name is used to drop the database during cleanup.
fn new_temp_test_db() !(&pg.DB, string) {
	name := 'vpm_test_${rand.u32()}'
	mut bootstrap := pg.connect(pg.Config{
		host:   'localhost'
		dbname: 'postgres'
		user:   'postgres'
	})!
	bootstrap.exec('CREATE DATABASE ${name}')!
	bootstrap.close()!
	db := pg.connect(pg.Config{
		host:   'localhost'
		dbname: name
		user:   'postgres'
	})!
	return db, name
}

fn drop_temp_test_db(name string) {
	mut bootstrap := pg.connect(pg.Config{
		host:   'localhost'
		dbname: 'postgres'
		user:   'postgres'
	}) or { return }
	bootstrap.exec('DROP DATABASE IF EXISTS ${name}') or {}
	bootstrap.close() or {}
}

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

// Verify that organization membership updates are atomic, a partial failure
// must roll back and leave the previous memberships unchanged.
fn test_save_user_organizations_rolls_back() {
	mut db, db_name := new_temp_test_db() or {
		eprintln('skipping: no local postgres reachable: ${err}')
		return
	}
	defer {
		db.close() or {}
		drop_temp_test_db(db_name)
	}

	sql db {
		create table UserOrganization
	} or {
		eprintln('skipping: could not create test table: ${err}')
		return
	}

	db.exec('ALTER TABLE userorganization ADD CONSTRAINT test_unique_membership UNIQUE (user_id, org_name)') or {
		eprintln('skipping: could not add test constraint: ${err}')
		return
	}

	mut orgs_repo := organizations(db)
	user_id := 424242

	orgs_repo.save_user_organizations(user_id, ['existing-org'])!
	assert orgs_repo.get_user_org_names(user_id) == ['existing-org']

	orgs_repo.save_user_organizations(user_id, ['new-org', 'new-org']) or {
		assert orgs_repo.get_user_org_names(user_id) == ['existing-org']
		return
	}
	assert false, 'save_user_organizations should have failed on the duplicate insert'
}

fn test_organization_migration_adds_user_index() {
	mut db, db_name := new_temp_test_db() or {
		eprintln('skipping: no local postgres reachable: ${err}')
		return
	}
	defer {
		db.close() or {}
		drop_temp_test_db(db_name)
	}

	migrate_organizations(db) or {
		assert false, 'migrate_organizations should succeed on a clean database: ${err}'
		return
	}

	rows := db.exec("SELECT indexname FROM pg_indexes WHERE tablename = 'userorganization' AND indexname = 'idx_userorganization_user_id'") or {
		assert false, 'index lookup query should succeed: ${err}'
		return
	}
	assert rows.len == 1
	migrate_organizations(db) or {
		assert false, 'migrate_organizations should be safe to run twice: ${err}'
		return
	}
}
