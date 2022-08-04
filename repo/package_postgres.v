module repo

import pg
import entity
import lib.sql

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

pub fn (r PackageRepo) create(package entity.Package) ?entity.Package {
	all := sql.to_idents<entity.Package>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(package, idents)

	query := 'insert into $repo.packages_table (${idents.join(', ')}) ' +
		'values (${values.join(', ')}) ' + 'returning ${all.join(', ')};'

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.Package>(row.vals, all)
}

pub fn (r PackageRepo) get(author string, name string) ?entity.Package {
	all := sql.to_idents<entity.Package>()

	query := 'select ${all.join(', ')} from $repo.packages_table ' +
		"where author = '$author' and name = '$name';"

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.Package>(row.vals, all)
}

pub fn (r PackageRepo) get_by_category_id(id int) ?[]entity.Package {
	all := sql.to_idents<entity.Package>()

	query := 'select ${all.join(', ')} from $repo.packages_table ' +
		'join $categories_packages_table cp on ${repo.packages_table}.id = cp.package_id ' +
		'where cp.category_id = $id;'

	rows := r.db.exec(query)?
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
pub fn (r PackageRepo) search(options SearchOptions) ?([]entity.Package, int) {
	all := sql.to_idents<entity.Package>()

	mut hidden := 'and is_hidden = false '

	if options.show_hidden {
		hidden = ''
	}

	// TODO: full text search through description
	// TODO: categories
	query := 'select ${all.join(', ')} from $repo.packages_table ' +
		"where name like '%$options.query%' " + hidden + '$options.to_sql();'

	rows := r.db.exec(query)?
	mut packages := []entity.Package{cap: rows.len}
	for _, row in rows {
		packages << sql.from_row_to<entity.Package>(row.vals, all)?
	}

	// TODO: total count for paginate
	return packages, packages.len
}

pub fn (r PackageRepo) update(package entity.Package) ?entity.Package {
	all := sql.to_idents<entity.Package>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(package, idents)
	set := sql.to_set(idents, values)

	query := 'update $repo.packages_table ' + 'set ${set.join(', ')} ' + 'where id = $package.id ' +
		'returning ${all.join(', ')};'

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.Package>(row.vals, all)
}
