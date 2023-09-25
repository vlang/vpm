module user

import entity { User }

interface UsersRepo {
	get(id int, random_id string) ?User
}

pub struct UseCase {
	users UsersRepo [required]
}

pub fn (u UseCase) get(id int, random_id string) ?User {
	return u.users.get(id, random_id)
}
