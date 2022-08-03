module package

import vpm.repo
import vpm.entity

pub interface CategoryRepo {
	create(category entity.Category) ?entity.Category
	add_to(category_id int, package_id int) ?
	get_by_slug(slug string) ?entity.Category
	get_by_package_id(package_id int) ?[]entity.Category
	get_all() ?[]entity.Category
	update(category entity.Category) ?entity.Category
}

pub interface PackageRepo {
	create(package entity.Package) ?entity.Package
	get(username string, name string) ?entity.Package
	get_by_category_id(id int) ?[]entity.Package
	search(options repo.SearchOptions) ?([]entity.Package, int)
	update(package entity.Package) ?entity.Package
}

pub interface TagRepo {
	create(tag entity.Tag) ?entity.Tag
	get_by_package_id(package_id int) ?[]entity.Tag
	update(tag entity.Tag) ?entity.Tag
}

pub interface UserRepo {
	get_by_username(username string) ?entity.User
}
