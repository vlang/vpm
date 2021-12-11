module service

import dto
import models
import repository

pub struct Users {
	repo repository.Users
	// TODO: auth token manager
}

pub fn new_users(repo repository.Users) Users {
	return Users{
		repo: repo
	}
}

pub fn (service Users) create(user dto.User) ?models.User {
	return service.repo.create(user) or { return wrap_err(err) }
}

pub fn (service Users) get_by_id(id int) ?models.User {
	return service.repo.get_by_id(id) or { return wrap_err(err) }
}

pub fn (service Users) get_by_github_id(id int) ?models.User {
	return service.repo.get_by_github_id(id) or { return wrap_err(err) }
}

pub fn (service Users) get_by_login(login string) ?models.User {
	return service.repo.get_by_login(login) or { return wrap_err(err) }
}

pub fn (service Users) update(input dto.User) ?models.User {
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
