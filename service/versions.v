module service

import vpm.models
import vpm.repository

pub struct VersionsService {
	repo repository.Versions
}

pub fn new_versions_service(repo repository.Versions) VersionsService {
	return VersionsService{
		repo: repo
	}
}

pub fn (service VersionsService) create(input CreateVersionInput) ?int {
	return service.repo.create(models.Version{
		package_id: input.package_id
		name: input.name
		commit_hash: input.commit_hash
		release_url: input.release_url
		dependencies: input.dependencies
		date: input.date
	}) or {
		return wrap_err(err)
	}
}

pub fn (service VersionsService) get(package_id int, name string) ?models.Version {
	return service.repo.get(package_id, name) or {
		return wrap_err(err)
	}
}

pub fn (service VersionsService) get_by_id(id int) ?models.Version {
	return service.repo.get_by_id(id) or {
		return wrap_err(err)
	}
}

pub fn (service VersionsService) get_by_package(package_id int) ?[]models.Version {
	return service.repo.get_by_package(package_id) or {
		return wrap_err(err)
	}
}

pub fn (service VersionsService) add_download(name string) ? {
	service.repo.add_download(name) or {
		return wrap_err(err)
	}
}

pub fn (service VersionsService) delete(name string) ? {
	service.repo.delete(name) or {
		return wrap_err(err)
	}
}
