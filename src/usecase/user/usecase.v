module user

import entity { User }

pub interface UsersRepo {
	get(id int, random_id string) ?User
	get_by_name(username string) ?User
}

pub struct UseCase {
pub:
	users UsersRepo @[required]
}

pub fn (u UseCase) get(id int, random_id string) ?User {
	return u.users.get(id, random_id)
}

pub fn (u UseCase) get_by_name(username string) ?User {
	return u.users.get_by_name(username)
}
