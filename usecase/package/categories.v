module package

import entity { Category, Package }
import arrays

pub interface CategoriesRepo {
	add_category_to_package(category_id int, package_id int) !
	get(slug string) !Category
	get_all() ![]Category
	get_category_packages(category_id int) ![]Package
	get_package_categories(package_id int) ![]Category
	update_category_stats(category_id int) !
}

pub fn (u UseCase) get_category(slug string) !Category {
	return u.categories.get(slug)
}

pub fn (u UseCase) get_categories() ![]Category {
	return u.categories.get_all()!
}

pub fn (u UseCase) get_category_packages(category_slug string) ?[]Package {
	cats := u.categories.get_all() or { return none }

	category := arrays.find_first(cats, fn [category_slug] (elem Category) bool {
		return category_slug == elem.slug
	}) or { return [] }

	return u.categories.get_category_packages(category.id) or { [] }
}

pub fn (u UseCase) get_package_categories(package_id int) ?[]Category {
	return u.categories.get_package_categories(package_id) or { [] }
}

pub fn (u UseCase) add_category_to_package(category_id int, package_id int) ! {
	u.categories.add_category_to_package(category_id, package_id)!
	u.categories.update_category_stats(category_id)!
}
