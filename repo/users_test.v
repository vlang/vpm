module repo

import db.pg
import entity { User }
import rand

fn new_temp_test_db() !(&pg.DB, string) {
	name := 'vpm_test_${rand.u32()}'
	mut bootstrap := pg.connect(pg.Config{
		host:   'localhost'
		dbname: 'postgres'
		user:   'postgres'
	})!
	bootstrap.exec('CREATE DATABASE ${name}')!
	bootstrap.close()!
	db := pg.connect(pg.Config{
		host:   'localhost'
		dbname: name
		user:   'postgres'
	})!
	return db, name
}

fn drop_temp_test_db(name string) {
	mut bootstrap := pg.connect(pg.Config{
		host:   'localhost'
		dbname: 'postgres'
		user:   'postgres'
	}) or { return }
	bootstrap.exec('DROP DATABASE IF EXISTS ${name}') or {}
	bootstrap.close() or {}
}

fn test_user_migration_adds_github_token() {
	mut db, db_name := new_temp_test_db() or {
		eprintln('skipping: no local postgres reachable: ${err}')
		return
	}
	defer {
		db.close() or {}
		drop_temp_test_db(db_name)
	}

	db.exec('CREATE TABLE "user" (
		id SERIAL PRIMARY KEY,
		github_id INT,
		username TEXT UNIQUE,
		avatar_url TEXT,
		is_blocked BOOL,
		block_reason TEXT,
		is_admin BOOL,
		random_id TEXT,
		created_at TIMESTAMP,
		updated_at TIMESTAMP
	)') or {
		eprintln('skipping: could not create pre-migration test table: ${err}')
		return
	}

	db.exec('INSERT INTO "user" (username, random_id) VALUES (\'preexisting\', \'abc\')') or {
		eprintln('skipping: could not seed test row: ${err}')
		return
	}

	migrate_users(db) or {
		assert false, 'migrate_users should upgrade an existing table, not fail: ${err}'
		return
	}

	mut users_repo := users(db)
	seeded := users_repo.get_by_name('preexisting') or {
		assert false, 'seeded user should still be readable after migration'
		return
	}

	users_repo.update_github_token(seeded.id, 'a-real-token') or {
		assert false, 'github_token column should exist and be writable after migrate_users: ${err}'
		return
	}

	user := users_repo.get_by_id(seeded.id) or {
		assert false, 'seeded user should still be readable after update'
		return
	}
	assert user.github_token == 'a-real-token'
	assert user.username == 'preexisting'
}

fn test_get_by_name_after_insert() {
	mut db, db_name := new_temp_test_db() or {
		eprintln('skipping: no local postgres reachable: ${err}')
		return
	}
	defer {
		db.close() or {}
		drop_temp_test_db(db_name)
	}

	migrate_users(db) or {
		assert false, 'migrate_users should succeed on a clean database: ${err}'
		return
	}

	new_user := User{
		username:  'fresh-install-user'
		random_id: 'xyz'
	}
	sql db {
		insert new_user into User
	} or {
		assert false, 'insert should succeed on a freshly migrated table: ${err}'
		return
	}

	mut users_repo := users(db)
	found := users_repo.get_by_name('fresh-install-user') or {
		assert false, 'get_by_name should find the just-inserted user on a clean install'
		return
	}
	assert found.username == 'fresh-install-user'
	assert found.random_id == 'xyz'

	db.q_int('select id from "User" where username=\'fresh-install-user\'') or {
		assert err.msg().contains('User') || err.msg().contains('does not exist')
		return
	}
	assert false, 'a raw query against "User" should fail on this schema'
}
