module repo

import pg
import time
import app_unused.entity
import lib.sql

const (
	auths_table = 'auths'
)

pub struct AuthRepo {
	db pg.DB
}

pub fn new_auth_repo(db pg.DB) AuthRepo {
	return AuthRepo{
		db: db
	}
}

pub fn (r AuthRepo) get(user_id int) ?entity.Auth {
	all := sql.to_idents[entity.Auth]()

	query := ['select ${all.join(', ')} from ${repo.auths_table} ',
		"where user_id = ${user_id} and kind = 'github_oauth';"].join(' ')

	row := r.db.exec_one(query)?
	return sql.from_row_to[entity.Auth](row.vals, all)
}

pub fn (r AuthRepo) create(auth entity.Auth) ?entity.Auth {
	all := sql.to_idents[entity.Auth]()
	idents := all.filter(it !in ['created_at', 'updated_at'])
	values := sql.to_values(auth, idents)

	query := ['insert into ${repo.auths_table} (${idents.join(', ')})',
		'values (${values.join(', ')}) returning ${all.join(', ')};'].join(' ')

	row := r.db.exec_one(query)?
	return sql.from_row_to[entity.Auth](row.vals, all)
}

pub fn (r AuthRepo) update(auth entity.Auth) ?entity.Auth {
	all := sql.to_idents[entity.Auth]()
	idents := all.filter(it != 'created_at')
	values := sql.to_values(entity.Auth{
		...auth
		updated_at: time.now()
	}, idents)
	set := sql.to_set(idents, values)

	query := ['update ${repo.auths_table} set ${set.join(', ')}',
		"where user_id = ${auth.user_id} and kind = '${auth.kind}'", 'returning ${all.join(', ')};'].join(' ')

	row := r.db.exec_one(query)?
	return sql.from_row_to[entity.Auth](row.vals, all)
}
