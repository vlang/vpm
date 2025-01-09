module repo

import orm
import entity { Package }

const banned_names = ['xxx']

const supported_vcs_systems = ['git']

pub struct PackagesRepo {
mut:
	db orm.Connection @[required]
}

pub fn migrate_packages(db orm.Connection) ! {
	sql db {
		create table Package
	}!
}

pub fn packages(db orm.Connection) PackagesRepo {
	return PackagesRepo{
		db: db
	}
}

fn (p PackagesRepo) all() []Package {
	pkgs := sql p.db {
		select from Package order by nr_downloads desc
	} or { [] }

	return pkgs
}

pub fn (p PackagesRepo) get_by_id(id int) !Package {
	rows := sql p.db {
		select from Package where id == id
	}!

	if rows.len == 0 {
		return error('Found no module with id: ${id}')
	}

	return rows[0]
}

fn (p PackagesRepo) find_by_query(query string) []Package {
	q := '%' + query + '%'
	pkgs := sql p.db {
		select from Package where name like q
	} or { [] }

	return pkgs
}

fn (p PackagesRepo) find_by_url(url string) []Package {
	return sql p.db {
		select from Package where url == url
	} or { [] }
}

fn (p PackagesRepo) count_by_user(user_id int) int {
	nr_pkgs := sql p.db {
		select count from Package where user_id == user_id
	} or { 0 }
	return nr_pkgs
}

fn (p PackagesRepo) find_by_user(user_id int) []Package {
	package := sql p.db {
		select from Package where user_id == user_id order by nr_downloads desc
	} or { [] }

	return package
}

fn (p PackagesRepo) get(name string) !Package {
	rows := sql p.db {
		select from Package where name == name
	}!

	if rows.len == 0 {
		return error('Found no module with name "${name}"')
	}

	return rows[0]
}

fn (p PackagesRepo) incr_downloads(name string) ! {
	sql p.db {
		update Package set nr_downloads = nr_downloads + 1 where name == name
	} or { return err }
}

pub fn (p PackagesRepo) delete(package_id int, user_id int) ! {
	sql p.db {
		delete from Package where id == package_id && user_id == user_id
	} or { return err }
}

pub fn (p PackagesRepo) create_package(package Package) ! {
	for bad_name in banned_names {
		if package.name.contains(bad_name) {
			return error('Package name contains banned word ${bad_name}')
		}
	}

	if package.url.contains(' ') || package.url.contains('%') || package.url.contains('<') {
		return error('Package url contains invalid characters')
	}

	if package.vcs !in supported_vcs_systems {
		return error('Package vcs system ${package.vcs} is not supported')
	}

	sql p.db {
		insert package into Package
	} or { return err }
}

pub fn (p PackagesRepo) get_recently_updated_packages() []Package {
	return sql p.db {
		select from Package order by updated_at desc limit 10
	} or { [] }
}

pub fn (p PackagesRepo) get_packages_count() int {
	return sql p.db {
		select count from Package
	} or { 0 }
}

pub fn (p PackagesRepo) get_new_packages() []Package {
	return sql p.db {
		select from Package order by created_at desc limit 10
	} or { [] }
}

pub fn (p PackagesRepo) get_most_downloaded_packages() []Package {
	return sql p.db {
		select from Package order by nr_downloads desc limit 10
	} or { [] }
}

pub fn (p PackagesRepo) update_package_stars(package_id int, stars int) ! {
	sql p.db {
		update Package set stars = stars where id == package_id
	}!
}

pub fn (p PackagesRepo) update_package_info(package_id int, name string, url string, description string) ! {
	sql p.db {
		update Package set name = name, url = url, description = description where id == package_id
	}!
}
