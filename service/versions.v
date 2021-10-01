module service

import dto
import models
import repository

pub struct Versions {
	repo &repository.Versions
}

pub fn new_versions(repo &repository.Versions) Versions {
	return Versions{
		repo: repo
	}
}

pub fn (service Versions) create(input dto.CreateVersionRequest) ?int {
	// return service.repo.create(models.Version{
	// 	package_id: input.package_id
	// 	tag: input.tag
	// 	dependencies: input.dependencies
	// 	commit_hash: input.commit_hash
	// 	release_url: input.release_url
	// 	date: input.date
	// }) or { return wrap_err(err) }
	println("service.version is not implemented")
	return -1
}

pub fn (service Versions) get(package_id int, name string) ?models.Version {
	return service.repo.get(package_id, name) or { return wrap_err(err) }
}

pub fn (service Versions) get_by_id(id int) ?models.Version {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Versions) get_by_package(package_id int) ?[]models.Version {
	return service.repo.get_by_package(package_id) or { return wrap_err(err) }
}

pub fn (service Versions) add_download(name string) ?models.Version {
	return service.repo.add_download(name) or { return wrap_err(err) }
}

pub fn (service Versions) delete(name string) ?models.Version {
	return service.repo.delete(name) or { return wrap_err(err) }
}
