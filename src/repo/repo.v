module repo

import orm

pub fn migrate(db orm.Connection) ! {
	migrate_categories(db)!
	migrate_packages(db)!
	migrate_users(db)!
	migrate_organizations(db)!
}
