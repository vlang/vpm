module repo

import pg
import time
import entity
import lib.sql

pub const (
	categories_packages_table = 'categories_packages'
	categories_table          = 'categories'
)

pub struct CategoryRepo {
	db pg.DB
}

pub fn new_category_repo(db pg.DB) CategoryRepo {
	return CategoryRepo{
		db: db
	}
}

pub fn (r CategoryRepo) create(category entity.Category) ?entity.Category {
	all := sql.to_idents<entity.Category>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(category, idents)

	query := ['insert into $repo.categories_table (${idents.join(', ')})',
		'values (${values.join(', ')}) returning ${all.join(', ')};'].join(' ')

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.Category>(row.vals, all)
}

// Many to Many connection
struct CategoryToPackage {
	category_id int
	package_id  int
}

pub fn (r CategoryRepo) add_to(category_id int, package_id int) ? {
	c2p := CategoryToPackage{
		category_id: category_id
		package_id: package_id
	}
	idents := sql.to_idents<CategoryToPackage>()
	values := sql.to_values(c2p, idents)

	query := ['insert into $repo.categories_packages_table (${idents.join(', ')})',
		'values (${values.join(', ')});'].join(' ')

	r.db.exec_one(query)?
}

pub fn (r CategoryRepo) get_by_slug(slug string) ?entity.Category {
	all := sql.to_idents<entity.Category>()

	query := "select ${all.join(', ')} from $repo.categories_table where slug = '$slug';"

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.Category>(row.vals, all)
}

pub fn (r CategoryRepo) get_by_package_id(package_id int) ?[]entity.Category {
	all := sql.to_idents<entity.Category>()

	query := ['select ${all.join(', ')} from $repo.categories_table',
		'join $repo.categories_packages_table',
		'on ${repo.categories_table}.id = ${repo.categories_packages_table}.category_id',
		'where ${repo.categories_packages_table}.package_id = $package_id;'].join(' ')

	rows := r.db.exec(query)?
	mut categories := []entity.Category{cap: rows.len}
	for _, row in rows {
		categories << sql.from_row_to<entity.Category>(row.vals, all)?
	}
	return categories
}

pub fn (r CategoryRepo) get_all() ?[]entity.Category {
	all := sql.to_idents<entity.Category>()

	query := 'select ${all.join(', ')} from $repo.categories_table;'

	rows := r.db.exec(query)?
	mut categories := []entity.Category{cap: rows.len}
	for _, row in rows {
		categories << sql.from_row_to<entity.Category>(row.vals, all)?
	}
	return categories
}

pub fn (r CategoryRepo) update(category entity.Category) ?entity.Category {
	all := sql.to_idents<entity.Category>()
	idents := all.filter(it !in ['id', 'created_at'])
	values := sql.to_values(entity.Category{
		...category,
		updated_at: time.now()
	}, idents)
	set := sql.to_set(idents, values)

	query := ['update $repo.categories_table set ${set.join(', ')}',
		'where id = $category.id returning ${all.join(', ')};'].join(' ')

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.Category>(row.vals, all)
}
