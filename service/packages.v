module service

import dto
import models
import repository

pub struct Packages {
	repo     repository.Packages
	versions repository.Versions
	// TODO: github api for getting markdown
}

pub fn new_packages(repo repository.Packages, versions repository.Versions) Packages {
	return Packages{
		repo: repo
		versions: versions
	}
}

pub fn (service Packages) create(package dto.NewPackage) ?models.Package {
	return service.repo.create(package) or { return wrap_err(err) }
}

pub fn (service Packages) get_by_id(id int) ?models.Package {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Packages) get_by_name(name string) ?models.Package {
	return service.repo.get_by_name(name) or { return wrap_err(err) }
}

pub fn (service Packages) get_by_author(author_id int) ?[]models.Package {
	return service.repo.get_by_author(author_id) or { return wrap_err(err) }
}

pub fn (service Packages) set_description(id int, description string) ? {
	service.repo.set_description(id, description) or { return wrap_err(err) }
}

pub fn (service Packages) set_stars(id int, stars int) ? {
	service.repo.set_stars(id, stars) or { return wrap_err(err) }
}

pub fn (service Packages) delete(id int) ? {
	service.repo.delete(id) or { return wrap_err(err) }
}

pub fn (service Packages) get_most_downloadable() ?[]models.Package {
	return service.repo.get_most_downloadable() or { return wrap_err(err) }
}

pub fn (service Packages) get_packages_count() ?int {
	return service.repo.get_packages_count() or { return wrap_err(err) }
}

pub fn (service Packages) add_version(version models.Version) ?models.Version {
	return service.versions.create(version) or { return wrap_err(err) }
}

pub fn (service Packages) get_versions(package_id int) ?[]models.Version {
	return service.versions.versions(package_id) or { return wrap_err(err) }
}

pub fn (service Packages) get_lastest_version(package_id int) ?models.Version {
	return service.versions.latest_version(package_id) or { return wrap_err(err) }
}

pub fn (service Packages) add_download(version_id int) ?models.Version {
	return service.versions.add_download(version_id) or { return wrap_err(err) }
}
