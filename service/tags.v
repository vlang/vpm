module service

import models
import repository

pub struct Tags {
	repo repository.Tags
	pkgs repository.Packages
}

pub fn new_tags(repo repository.Tags, pkgs repository.Packages) Tags {
	return Tags{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service Tags) create(slug string, name string) ?models.Tag {
	return service.repo.create(slug, name) or { return wrap_err(err) }
}

pub fn (service Tags) get_by_id(id int) ?models.Tag {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Tags) get_by_slug(slug string) ?models.Tag {
	return service.repo.get_by_slug(slug) or { return wrap_err(err) }
}

pub fn (service Tags) get_packages(id int) ?[]models.Package {
	ids := service.repo.get_packages(id) or { return wrap_err(err) }
	pkgs := service.pkgs.get_by_ids(...ids) or { return wrap_err(err) }
	return pkgs
}

pub fn (service Tags) all() ?[]models.Tag {
	return service.repo.all() or { return wrap_err(err) }
}

pub fn (service Tags) delete(id int) ?models.Tag {
	return service.repo.delete(id) or { return wrap_err(err) }
}
