module package

import vpm.entity

fn (u UseCase) to_full_package(package entity.Package) ?entity.FullPackage {
	author := u.user.get_by_username(package.author) ?
	categories := u.category.get_by_package_id(package.id) ?
	tags := u.tag.get_by_package_id(package.id) ?

	return entity.FullPackage{
		Package: package
		author: author
		categories: categories
		tags: tags
	}
}
