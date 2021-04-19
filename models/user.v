module models

pub interface UserService {
	create_user(user User) ?User
	get_user(id int) ?User
	get_users_by_name(like string, limit int) ?[]User
	update_user(user User) ?User
	delete_user(id int) ?User
}

pub struct User {
pub:
	id         int
	username   string
	avatar_url         string [json: avatarUrl]
	is_blocked bool [skip]
	is_admin   bool [skip]
pub mut:
	login_attempts int [skip]
}

pub fn user_from_map(f map[string]string) ?User {
	for field in ['id', 
		'username',
		'avatarUrl'] {
		if field !in f {
			return error('Not enough array elements to form user from map')
		}
	}
	return User{
		id: f['id'].int()
		username: f['username']
		avatar_url: f['avatarUrl']
	}
}