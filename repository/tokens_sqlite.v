module repository

import sqlite
import models

pub struct TokensRepo {
	db sqlite.DB
}

pub fn new_tokens_repo(db sqlite.DB) TokensRepo {
	return TokensRepo{
		db: db
	}
}

pub fn (r TokensRepo) update(user_id string, access_token string) ? {}

pub fn (r TokensRepo) get(user_id string) ?models.Token {
	return error('ass')
}

pub fn (r TokensRepo) delete(user_id string) ? {}
