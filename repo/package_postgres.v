module repo

import pg
import vpm.entity
import vpm.lib.sql

const (
	packages_table = 'packages'
)

pub struct PackageRepo {
	db pg.DB
}

pub fn new_package_repo(db pg.DB) PackageRepo {
	return PackageRepo{
		db: db
	}
}

pub fn (repo PackageRepo) create(package entity.Package) ?entity.Package {
	all := sql.to_idents<entity.Package>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(package, idents)

	query := 'insert into $packages_table (${idents.join(', ')}) ' +
		'values (${values.join(', ')}) '+
		'returning ${all.join(', ')};'

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Package>(row.vals, all)
}

pub fn (repo PackageRepo) get(author string, name string) ?entity.Package {
	all := sql.to_idents<entity.Package>()

	query := 'select ${all.join(', ')} from $packages_table ' +
		"where author = '$author' and name = '$name';"

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Package>(row.vals, all)
}

pub fn (repo PackageRepo) get_by_category_id(id int) ?[]entity.Package {
	all := sql.to_idents<entity.Package>()

	query := 'select ${all.join(', ')} from $packages_table ' +
		'join $categories_packages_table cp on ${packages_table}.id = cp.package_id '+
		"where cp.category_id = $id;"

	rows := repo.db.exec(query)?
	mut packages := []entity.Package{cap: rows.len}
	for _, row in rows {
		packages << sql.from_row_to<entity.Package>(row.vals, all)?
	}
	return packages
}

pub struct SearchOptions {
	sql.Options
pub mut:
	query string
	// Hidden from home page
	show_hidden bool = true
}

// Returns result and total count
pub fn (repo PackageRepo) search(options SearchOptions) ?([]entity.Package, int) {
	all := sql.to_idents<entity.Package>()

	mut hidden := 'and is_hidden = false '

	if options.show_hidden {
		hidden = ''
	}

	// TODO: full text search through description
	// TODO: categories
	query := 'select ${all.join(', ')} from $packages_table ' +
		"where name like '%$options.query%' " + hidden +
		'${options.to_sql()};'

	rows := repo.db.exec(query)?
	mut packages := []entity.Package{cap: rows.len}
	for _, row in rows {
		packages << sql.from_row_to<entity.Package>(row.vals, all)?
	}

	// TODO: total count for paginate
	return packages, packages.len
}

pub fn (repo PackageRepo) update(package entity.Package) ?entity.Package {
	all := sql.to_idents<entity.Package>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(package, idents)
	set := sql.to_set(idents, values)

	query := 'update $packages_table ' +
		'set ${set.join(', ')} '+
		'where id = $package.id '+
		'returning ${all.join(', ')};'

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Package>(row.vals, all)
}
