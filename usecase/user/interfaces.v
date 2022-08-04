module user

import entity

pub interface AuthRepo {
	get_by_user(username string) ?entity.Auth
	upsert(auth entity.Auth) ?entity.Auth
}

pub interface UserRepo {
	create(user entity.User) ?entity.User
	get_by_username(username string) ?entity.User
	update(user entity.User) ?entity.User
}
