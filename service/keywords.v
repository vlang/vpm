module service

import models
import repository

pub struct Keywords {
	repo repository.Keywords
	pkgs repository.Packages
}

pub fn new_keywords(repo repository.Keywords, pkgs repository.Packages) Keywords {
	return Keywords{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service Keywords) create(slug string, name string) ?models.Keyword {
	return service.repo.create(slug, name) or { return wrap_err(err) }
}

pub fn (service Keywords) get_by_id(id int) ?models.Keyword {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Keywords) get_by_slug(slug string) ?models.Keyword {
	return service.repo.get_by_slug(slug) or { return wrap_err(err) }
}

pub fn (service Keywords) get_packages(id int) ?[]models.Package {
	ids := service.repo.get_packages(id) or { return wrap_err(err) }
	pkgs := service.pkgs.get_by_ids(...ids) or { return wrap_err(err) }
	return pkgs
}

pub fn (service Keywords) all() ?[]models.Keyword {
	return service.repo.all() or { return wrap_err(err) }
}

pub fn (service Keywords) delete(id int) ?models.Keyword {
	return service.repo.delete(id) or { return wrap_err(err) }
}
