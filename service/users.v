module service

import dto
import models
import repository

pub struct Users {
	repo &repository.Users
	pkgs &repository.Packages
	// TODO: auth token manager
}

pub fn new_users(repo &repository.Users, pkgs &repository.Packages) Users {
	return Users{
		repo: repo
		pkgs: pkgs
	}
}

pub fn (service Users) create(input dto.CreateUserRequest) ?models.User {
	return service.repo.create(models.User{
		github_id: input.github_id
		login: input.login
		avatar_url: input.avatar_url
	}) or { return wrap_err(err) }
}

pub fn (service Users) get_by_id(id int) ?models.User {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Users) get_by_github_id(id int) ?models.User {
	return service.repo.get_by_github_id(id) or { return wrap_err(err) }
}

pub fn (service Users) get_by_username(username string) ?models.User {
	return service.repo.get_by_username(username) or { return wrap_err(err) }
}

pub fn (service Users) get_packages(id int) ?[]models.Package {
	return service.pkgs.get_by_author(id) or { return wrap_err(err) }
}

pub fn (service Users) update(input dto.UpdateUserRequest) ?models.User {
	println(input)
	return error("I'm a teapot")
}

pub fn (service Users) set_blocked(id int, is_blocked bool) ?models.User {
	return service.repo.set_blocked(id, is_blocked) or { return wrap_err(err) }
}

pub fn (service Users) set_admin(id int, is_admin bool) ?models.User {
	return service.repo.set_admin(id, is_admin) or { return wrap_err(err) }
}

pub fn (service Users) update_token(github_id int, access_token string) ?int {
	// TODO with auth token manager
	panic('not implemented')
}

pub fn (service Users) verify(jwt_token string) ?int {
	// TODO with auth token manager
	panic('not implemented')
}
