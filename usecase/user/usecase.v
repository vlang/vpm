module user

import config
import lib.github
import lib.log
import repo
import entity

pub struct UseCase {
	cfg  config.Github
	auth repo.AuthRepo
	user repo.UserRepo
}

pub fn new_use_case(cfg config.Github, auth repo.AuthRepo, user repo.UserRepo) UseCase {
	return UseCase{
		cfg: cfg
		auth: auth
		user: user
	}
}

// Authenticate via github
pub fn (u UseCase) authenticate(access_token string) ?entity.User {
	c := github.new_client(access_token)
	gh_user := c.current_user()?

	log.info()
		.add('username', gh_user.login)
		.msg('fetched github user')

	mut user := entity.User{
		username: gh_user.login
		name: gh_user.name
		avatar_url: gh_user.avatar_url
	}

	// Upserting user
	if mut upd := u.user.get_by_username(user.username) {
		upd.username = user.username
		upd.name = user.name
		upd.avatar_url = user.avatar_url

		log.info()
			.add('username', user.username)
			.msg('updating user at auth')

		user = u.user.update(upd)?
	} else {
		log.info()
			.add('username', user.username)
			.msg('creating new user')

		user = u.user.create(user)?
	}

	if mut auth := u.auth.get_by_username(user.username) {
		auth.value = access_token

		log.info()
			.add('username', auth.username)
			.add('kind', auth.kind)
			.msg('updating user auth')

		u.auth.update(auth)?
	} else {
		log.info()
			.add('error', err.str())
			.msg('if not found auth, fine')

		auth := entity.Auth{
			username: user.username
			value: access_token
		}

		log.info()
			.add('username', auth.username)
			.add('kind', auth.kind)
			.msg('creating user auth')

		u.auth.create(auth)?
	}

	return user
}

// Get
pub fn (u UseCase) get_by_username(username string) ?entity.User {
	user := u.user.get_by_username(username)?

	log.info()
		.add('username', user.username)
		.msg('user by username')

	return user
}
