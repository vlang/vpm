module models

pub interface TokenService {
	create_token(user_id string, ip string) ?(token string)
	is_valid(token string, user_id int, ip string) ?bool
	update_user_token(token string, user_id int, ip string) ?(token string)
	clear_sessions(user_id string) ?
}

pub struct Token {
pub:
	id      int
	user_id int
	ip      string
	value   string
}