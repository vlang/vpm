module repo

import orm
import entity { UserOrganization }

pub struct OrganizationsRepo {
mut:
	db orm.Connection @[required]
}

pub fn migrate_organizations(db orm.Connection) ! {
	sql db {
		create table UserOrganization
	}!
}

pub fn organizations(db orm.Connection) OrganizationsRepo {
	return OrganizationsRepo{
		db: db
	}
}

pub fn (o OrganizationsRepo) get_user_organizations(user_id int) []UserOrganization {
	return sql o.db {
		select from UserOrganization where user_id == user_id
	} or { [] }
}

pub fn (o OrganizationsRepo) get_user_org_names(user_id int) []string {
	orgs := o.get_user_organizations(user_id)
	mut names := []string{cap: orgs.len}
	for org in orgs {
		names << org.org_name
	}
	return names
}

pub fn (o OrganizationsRepo) user_belongs_to_org(user_id int, org_name string) bool {
	orgs := sql o.db {
		select from UserOrganization where user_id == user_id && org_name == org_name
	} or { [] }
	return orgs.len > 0
}

pub fn (o OrganizationsRepo) save_user_organizations(user_id int, org_names []string) ! {
	// Delete existing organizations for this user
	sql o.db {
		delete from UserOrganization where user_id == user_id
	} or {}

	// Insert new organizations
	for org_name in org_names {
		org := UserOrganization{
			user_id:  user_id
			org_name: org_name
		}
		sql o.db {
			insert org into UserOrganization
		} or { continue }
	}
}
