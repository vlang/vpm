module service

import models
import repository

pub struct CategoriesService {
	repo repository.Categories
	pkgs repository.Packages
}

pub fn new_categories_service(repo repository.Categories, pkgs repository.Packages) CategoriesService {
	return CategoriesService{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service CategoriesService) create(name string) ?int {
	return service.repo.create(name) or { return wrap_err(err) }
}

pub fn (service CategoriesService) get_by_id(id int) ?models.Category {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service CategoriesService) get_by_name(name string) ?models.Category {
	return service.repo.get_by_name(name) or { return wrap_err(err) }
}

pub fn (service CategoriesService) get_by_package(id int) ?[]models.Category {
	return service.repo.get_by_package(id) or { return wrap_err(err) }
}

pub fn (service CategoriesService) get_packages(name string) ?[]models.Package {
	ids := service.repo.get_packages(name) or { return wrap_err(err) }

	pkgs := service.pkgs.get_by_ids(...ids) or { return wrap_err(err) }

	return pkgs
}

pub fn (service CategoriesService) get_popular_categories() ?[]models.Category {
	return service.repo.get_popular_categories() or { return wrap_err(err) }
}

pub fn (service CategoriesService) get_all() ?[]models.Category {
	return service.repo.get_all() or { return wrap_err(err) }
}

pub fn (service CategoriesService) add_package(id int, package_id int) ? {
	service.repo.add_package(id, package_id) or { return wrap_err(err) }
}

pub fn (service CategoriesService) delete(name string) ? {
	service.repo.delete(name) or { return wrap_err(err) }
}
