module repository

import sqlite

pub struct TokensRepo {
	db sqlite.DB
}

pub fn new_tokens_repo(db sqlite.DB) TokensRepo {
	return TokensRepo{
		db: db
	}
}

pub fn (r TokensRepo) find_token(user_id int, ip string) ?string {
	return exec_field(r.db, "SELECT value FROM $tokens_table WHERE user_id = $user_id AND ip = '$ip';")
}

pub fn (r TokensRepo) update_token(token string, user_id int, ip string) ?string {
	value := r.find_token(user_id, ip) or {
		exec(r.db, 'INSERT INTO $tokens_table SET (user_id, value, ip)' +
			"VALUES ($user_id, '$token', '$ip');") ?
		r.find_token(user_id, ip) ?
	}
	return value
}

pub fn (r TokensRepo) is_valid(token string, user_id int, ip string) ?bool {
	value := r.find_token(user_id, ip) or {
		if err.msg == 'No rows' {
			return false
		}
		return err
	}
	return value == token
}

pub fn (r TokensRepo) clear_tokens(user_id int) ? {
	exec(r.db, 'DELETE FROM $tokens_table WHERE user_id = $user_id;') ?
}
