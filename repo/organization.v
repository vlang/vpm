module repo

import orm
import db.pg
import entity { UserOrganization }

pub struct OrganizationsRepo {
mut:
	db pg.DB @[required]
}

pub fn migrate_organizations(db orm.Connection) ! {
	sql db {
		create table UserOrganization
	}!
	mut db_mut := db
	db_mut.execute('CREATE INDEX IF NOT EXISTS idx_userorganization_user_id ON userorganization (user_id)')!
}

pub fn organizations(db pg.DB) OrganizationsRepo {
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

pub fn (mut o OrganizationsRepo) save_user_organizations(user_id int, org_names []string) ! {
	mut tx := o.db.begin(pg.PQTransactionParam{})!

	sql tx {
		delete from UserOrganization where user_id == user_id
	} or {
		tx.rollback() or {}
		return err
	}

	for org_name in org_names {
		org := UserOrganization{
			user_id:  user_id
			org_name: org_name
		}
		sql tx {
			insert org into UserOrganization
		} or {
			tx.rollback() or {}
			return err
		}
	}

	tx.commit()!
}
