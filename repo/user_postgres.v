module repo

import pg
import entity
import lib.sql

const (
	users_table = 'users'
)

pub struct UserRepo {
	db pg.DB
}

pub fn new_user_repo(db pg.DB) UserRepo {
	return UserRepo{
		db: db
	}
}

pub fn (r UserRepo) create(user entity.User) ?entity.User {
	all := sql.to_idents<entity.User>()
	idents := all.filter(it !in ['created_at', 'updated_at'])
	values := sql.to_values(user, idents)

	query := 'insert into $repo.users_table (${idents.join(', ')}) ' +
		'values (${values.join(', ')}) ' + 'returning ${all.join(', ')};'

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.User>(row.vals, all)
}

pub fn (r UserRepo) get_by_username(username string) ?entity.User {
	all := sql.to_idents<entity.User>()

	query := 'select ${all.join(', ')} from $repo.users_table ' + "where username = '$username';"

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.User>(row.vals, all)
}

pub fn (r UserRepo) update(user entity.User) ?entity.User {
	all := sql.to_idents<entity.User>()
	idents := all.filter(it != 'created_at')
	values := sql.to_values(user, idents)
	set := sql.to_set(idents, values)

	query := 'update $repo.users_table ' + 'set ${set.join(', ')} ' +
		"where username = '$user.username' " + 'returning ${all.join(', ')};'

	row := r.db.exec_one(query)?
	return sql.from_row_to<entity.User>(row.vals, all)
}
