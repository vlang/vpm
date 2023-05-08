module repo

import pg
import time
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
	all := sql.to_idents[entity.Package]()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(package, idents)

	query := 'insert into ${repo.packages_table} (${idents.join(', ')}) ' +
		'values (${values.join(', ')}) ' + 'returning ${all.join(', ')};'

	row := r.db.exec_one(query)?
	return sql.from_row_to[entity.Package](row.vals, all)
}

pub fn (r PackageRepo) get(author_id int, name string) ?entity.Package {
	all := sql.to_idents[entity.Package]()

	query := 'select ${all.join(', ')} from ${repo.packages_table} ' +
		"where author_id = ${author_id} and name = '${name}';"

	row := r.db.exec_one(query)?
	return sql.from_row_to[entity.Package](row.vals, all)
}

pub fn (r PackageRepo) get_by_author(author_id int) ?[]entity.Package {
	all := sql.to_idents[entity.Package]()

	query := 'select ${all.join(', ')} from ${repo.packages_table} ' +
		'where author_id = ${author_id};'

	rows := r.db.exec(query)?
	mut packages := []entity.Package{cap: rows.len}
	for _, row in rows {
		packages << sql.from_row_to[entity.Package](row.vals, all)?
	}
	return packages
}

pub fn (r PackageRepo) get_by_category_id(category_id int) ?[]entity.Package {
	all := sql.to_idents[entity.Package]()

	query := 'select ${all.join(', ')} from ${repo.packages_table} ' +
		'join ${categories_packages_table} cp on ${repo.packages_table}.id = cp.package_id ' +
		'where cp.category_id = ${category_id};'

	rows := r.db.exec(query)?
	mut packages := []entity.Package{cap: rows.len}
	for _, row in rows {
		packages << sql.from_row_to[entity.Package](row.vals, all)?
	}
	return packages
}

pub struct SearchOptions {
	sql.Options
pub mut:
	query       string
	category    string
	show_hidden bool = true
}

// Returns result and total count
pub fn (r PackageRepo) search(options SearchOptions) ?([]entity.Package, int) {
	all := sql.to_idents[entity.Package]()

	mut where_clause := []string{}

	if options.query.len > 0 {
		where_clause << "name like '%${options.query}%'"
	}

	if options.category.len > 0 {
		where_clause << "c.slug = '${options.category}'"
	}

	if !options.show_hidden {
		where_clause << 'is_hidden = false'
	}

	opts := options.to_sql()?

	// TODO: full text search through description
	query := 'select ${all.map('p.${it}').join(', ')}, count(*) over() as total from ${repo.packages_table} p ' + if options.category.len > 0 {
		'join categories_packages cp on p.id = cp.package_id ' + 'join categories c on c.id = cp.category_id '
	} else {
		''
	} + if where_clause.len > 0 {
		'where ' + where_clause.join(' and ')
	} else {
		''
	} + opts.join(' ') + ';'

	mut total := 0
	rows := r.db.exec(query)?
	mut packages := []entity.Package{cap: rows.len}
	for _, row in rows {
		if total == 0 {
			total = row.vals.last().int()
		}

		packages << sql.from_row_to[entity.Package](row.vals#[0..-1], all)?
	}

	return packages, total
}

pub fn (r PackageRepo) update(package entity.Package) ?entity.Package {
	all := sql.to_idents[entity.Package]()
	idents := all.filter(it !in ['id', 'created_at'])
	values := sql.to_values(entity.Package{
		...package
		updated_at: time.now()
	}, idents)
	set := sql.to_set(idents, values)

	query := 'update ${repo.packages_table} ' + 'set ${set.join(', ')} ' +
		'where id = ${package.id} ' + 'returning ${all.join(', ')};'

	row := r.db.exec_one(query)?
	return sql.from_row_to[entity.Package](row.vals, all)
}
