module service

import models
import repository

pub struct PackagesService {
	repo repository.Packages
	// TODO: github api for getting markdown
}

pub fn new_packages_service(repo repository.Packages) PackagesService {
	return PackagesService{
		repo: repo
	}
}

pub fn (service PackagesService) create(input CreatePackageInput) ?int {
	return service.repo.create(models.Package{
		author_id: input.author_id
		name: input.name
		description: input.description
		license: input.license
		vcs: input.vcs
		repo_url: input.repo_url
	}) or { return wrap_err(err) }
}

pub fn (service PackagesService) get_by_id(id int) ?models.Package {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service PackagesService) get_by_name(name string) ?models.Package {
	return service.repo.get_by_name(name) or { return wrap_err(err) }
}

pub fn (service PackagesService) get_by_author(author_id int) ?[]models.Package {
	return service.repo.get_by_author(author_id) or { return wrap_err(err) }
}

pub fn (service PackagesService) set_description(name string, description string) ? {
	service.repo.set_description(name, description) or { return wrap_err(err) }
}

pub fn (service PackagesService) set_stars(name string, stars int) ? {
	service.repo.set_stars(name, stars) or { return wrap_err(err) }
}

pub fn (service PackagesService) add_download(name string) ? {
	service.repo.add_download(name) or { return wrap_err(err) }
}

pub fn (service PackagesService) delete(name string) ? {
	service.repo.delete(name) or { return wrap_err(err) }
}

pub fn (service PackagesService) get_most_downloadable() ?[]models.Package {
	return service.repo.get_most_downloadable() or { return wrap_err(err) }
}

pub fn (service PackagesService) get_most_recent_downloads() ?[]models.Package {
	return service.repo.get_most_recent_downloads() or { return wrap_err(err) }
}

pub fn (service PackagesService) get_new_packages() ?[]models.Package {
	return service.repo.get_new_packages() or { return wrap_err(err) }
}

pub fn (service PackagesService) get_recently_updated() ?[]models.Package {
	return service.repo.get_recently_updated() or { return wrap_err(err) }
}

pub fn (service PackagesService) get_packages_count() ?int {
	return service.repo.get_packages_count() or { return wrap_err(err) }
}
