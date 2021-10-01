module service

import models
import repository

pub struct Tags {
	repo &repository.Tags
	pkgs &repository.Packages
}

pub fn new_tags(repo &repository.Tags, pkgs &repository.Packages) Tags {
	return Tags{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service Tags) create(name string) ?models.Tag {
	return service.repo.create(name) or { return wrap_err(err) }
}

pub fn (service Tags) get_by_id(id int) ?models.Tag {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Tags) get_by_name(name string) ?models.Tag {
	return service.repo.get_by_name(name) or { return wrap_err(err) }
}

pub fn (service Tags) get_by_package(id int) ?[]models.Tag {
	return service.repo.get_by_package(id) or { return wrap_err(err) }
}

pub fn (service Tags) get_packages(name string) ?[]models.Package {
	ids := service.repo.get_packages(name) or { return wrap_err(err) }
	pkgs := service.pkgs.get_by_ids(...ids) or { return wrap_err(err) }
	return pkgs
}

pub fn (service Tags) get_popular_tags() ?[]models.Tag {
	// return service.repo.get_popular_tags() or { return wrap_err(err) }
	return error('not implemented')
}

pub fn (service Tags) get_all() ?[]models.Tag {
	return service.repo.get_all() or { return wrap_err(err) }
}

pub fn (service Tags) add_package(id int, package_id int) ?models.Tag {
	return service.repo.add_package(id, package_id) or { return wrap_err(err) }
}

pub fn (service Tags) delete(name string) ?models.Tag {
	return service.repo.delete(name) or { return wrap_err(err) }
}
