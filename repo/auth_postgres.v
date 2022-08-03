module repo

import pg
import vpm.entity
import vpm.lib.sql

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

pub fn (repo AuthRepo) get_by_username(username string) ?entity.Auth {
	all := sql.to_idents<entity.Auth>()

	query := 'select ${all.join(', ')} from $auths_table ' +
		"where username = '$username' and kind = 'github_oauth';"

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Auth>(row.vals, all)
}

pub fn (repo AuthRepo) create(auth entity.Auth) ?entity.Auth {
	all := sql.to_idents<entity.Auth>()
	idents := all.filter(it !in ['created_at', 'updated_at'])
	values := sql.to_values(auth, idents)

	query := 'insert into $auths_table (${idents.join(', ')}) ' +
		'values (${values.join(', ')}) '+
		'returning ${all.join(', ')};'

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Auth>(row.vals, all)
}

pub fn (repo AuthRepo) update(auth entity.Auth) ?entity.Auth {
	all := sql.to_idents<entity.Auth>()
	idents := all.filter(it !in ['created_at'])
	values := sql.to_values(auth, idents)
	set := sql.to_set(idents, values)

	query := 'update $auths_table ' +
		'set ${set.join(', ')} '+
		"where username = '$auth.username' and kind = '$auth.kind' "+
		'returning ${all.join(', ')};'

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Auth>(row.vals, all)
}
