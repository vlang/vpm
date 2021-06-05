module service

import vpm.models
import vpm.repository

pub struct UsersService {
	repo repository.Users
	pkgs repository.Packages
	// TODO: auth token manager
}

pub fn new_users_service(repo repository.Users, pkgs repository.Packages) UsersService {
	return UsersService{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service UsersService) create(input CreateUserInput) ?int {
	return service.repo.create(models.User{
		github_id: input.github_id
		username: input.username
		avatar_url: input.avatar_url
	}) or {
		return wrap_err(err)
	}
}

pub fn (service UsersService) get_by_id(id int) ?models.User {
	return service.repo.get_by_id(id) or {
		return wrap_err(err)
	}
}

pub fn (service UsersService) get_by_github_id(id int) ?models.User {
	return service.repo.get_by_github_id(id) or {
		return wrap_err(err)
	}
}

pub fn (service UsersService) get_by_username(username string) ?models.User {
	return service.repo.get_by_username(username) or {
		return wrap_err(err)
	}
}

pub fn (service UsersService) get_packages(id int) ?[]models.Package {
	return service.pkgs.get_by_author(id) or {
		return wrap_err(err)
	}
}

pub fn (service UsersService) update(input UpdateUserInput) ? {
	panic('no')
}

pub fn (service UsersService) set_blocked(id int, is_blocked bool) ? {
	service.repo.set_blocked(id, is_blocked) or {
			return wrap_err(err)
		}
}

pub fn (service UsersService) set_admin(id int, is_admin bool) ? {
	service.repo.set_admin(id, is_admin) or {
			return wrap_err(err)
		}
}

pub fn (service UsersService) update_token(github_id int, access_token string) ?int {
	// TODO with auth token manager
	panic('not implemented')
}

pub fn (service UsersService) verify(jwt_token string) ?int {
	// TODO with auth token manager
	panic('not implemented')
}
