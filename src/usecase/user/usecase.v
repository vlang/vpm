module user

import repo
import entity { User }

pub struct UseCase {
	users repo.Users
}

pub fn (u UseCase) get(id int, random_id string) ?User {
	return u.users.get(id, random_id)
}
