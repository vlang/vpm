module service

import vpm.models
import vpm.repository

pub struct TagsService {
	repo repository.Tags
	pkgs repository.Packages
}

pub fn new_tags_service(repo repository.Tags, pkgs repository.Packages) TagsService {
	return TagsService{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service TagsService) create(name string) ?int {
	return service.repo.create(name) or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) get_by_id(id int) ?models.Tag {
	return service.repo.get_by_id(id) or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) get_by_name(name string) ?models.Tag {
	return service.repo.get_by_name(name) or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) get_by_package(id int) ?[]models.Tag {
	return service.repo.get_by_package(id) or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) get_packages(name string) ?[]models.Package {
	ids := service.repo.get_packages(name) or {
		return wrap_err(err)
	}

	pkgs := service.pkgs.get_by_ids(...ids) or {
		return wrap_err(err)
	}

	return pkgs
}

pub fn (service TagsService) get_popular_tags() ?[]models.Tag {
	return service.repo.get_popular_tags() or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) get_all() ?[]models.Tag {
	return service.repo.get_all() or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) add_package(id int, package_id int) ? {
	service.repo.add_package(id, package_id) or {
		return wrap_err(err)
	}
}

pub fn (service TagsService) delete(name string) ? {
	service.repo.delete(name) or {
		return wrap_err(err)
	}
}

