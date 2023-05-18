module repo

import db.pg
import entity
import lib.log

const banned_names = ['xxx']

const supported_vcs_systems = ['git']

interface Packages {
	all() []entity.Package
	get(name string) !entity.Package
	find_by_query(query string) []entity.Package
	find_by_url(url string) []entity.Package
	find_by_user(user_id int) []entity.Package
	count_by_user(user_id int) int
	incr_downloads(name string) !
	create_package(package entity.Package) !
	delete(package_id int, user_id int) !
	get_recently_updated_packages() []entity.Package
	get_packages_count() int
	get_new_packages() []entity.Package
	get_most_downloaded_packages() []entity.Package
}

pub struct PackagesRepo {
pub mut:
	db pg.DB
}

fn (p PackagesRepo) all() []entity.Package {
	pkgs := sql p.db {
		select from entity.Package order by downloads desc
	} or { [] }

	log.info()
		.add('package count', pkgs.len)
		.msg('all pkgs')

	return pkgs
}

fn (p PackagesRepo) find_by_query(query string) []entity.Package {
	q := '%' + query + '%'
	pkgs := sql p.db {
		select from entity.Package where name like q
	} or { [] }

	log.info()
		.add('count', pkgs.len)
		.msg('found pkgs by query "${q}"')

	return pkgs
}

fn (p PackagesRepo) find_by_url(url string) []entity.Package {
	return sql p.db {
		select from entity.Package where url == url
	} or { [] }
}

fn (p PackagesRepo) count_by_user(user_id int) int {
	nr_pkgs := sql p.db {
		select count from entity.Package where user_id == user_id
	} or { 0 }
	return nr_pkgs
}

fn (p PackagesRepo) find_by_user(user_id int) []entity.Package {
	mod := sql p.db {
		select from entity.Package where user_id == user_id order by downloads desc
	} or { [] }
	return mod
}

fn (p PackagesRepo) get(name string) !entity.Package {
	rows := sql p.db {
		select from entity.Package where name == name
	}!

	if rows.len == 0 {
		return error('Found no module with name "${name}"')
	}
	return rows[0]
}

fn (p PackagesRepo) incr_downloads(name string) ! {
	sql p.db {
		update entity.Package set downloads = downloads + 1 where name == name
	} or { return err }
}

pub fn (p PackagesRepo) delete(package_id int, user_id int) ! {
	sql p.db {
		delete from entity.Package where id == package_id && user_id == user_id
	} or { return err }
}

pub fn (p PackagesRepo) create_package(package entity.Package) ! {
	for bad_name in repo.banned_names {
		if package.name.contains(bad_name) {
			return error('package name contains banned word ${bad_name}')
		}
	}
	if package.url.contains(' ') || package.url.contains('%') || package.url.contains('<') {
		return error('package url contains invalid characters')
	}
	if package.vcs !in repo.supported_vcs_systems {
		return error('package vcs system ${package.vcs} is not supported')
	}
	sql p.db {
		insert package into entity.Package
	} or { return err }
}

pub fn (p PackagesRepo) get_recently_updated_packages() []entity.Package {
	return sql p.db {
		select from entity.Package order by updated_at desc limit 10
	} or { [] }
}

pub fn (p PackagesRepo) get_packages_count() int {
	return sql p.db {
		select count from entity.Package
	} or { 0 }
}

pub fn (p PackagesRepo) get_new_packages() []entity.Package {
	return sql p.db {
		select from entity.Package order by created_at limit 10
	} or { [] }
}

pub fn (p PackagesRepo) get_most_downloaded_packages() []entity.Package {
	return sql p.db {
		select from entity.Package order by downloads limit 10
	} or { [] }
}
