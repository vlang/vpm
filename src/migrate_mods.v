module main

// Old definition
struct Mod {
	id           int    [primary; sql: serial]
	name         string
	description  string
	url          string
	nr_downloads int
	vcs          string = 'git'
}

struct OldUser {
	id        int
	name      string
	random_id string
}

fn (mut app App) migrate_old_modules() ! {
	old_mods := sql app.db {
		select from Mod
	}!
	for mod in old_mods {
		vals := mod.name.split('.')
		username := if vals.len > 1 {
			vals[0]
		} else {
			'medvednikov'
		}

		old_users := sql app.db {
			select from OldUser where name == username
		}!
		if old_users.len == 0 {
			continue
		}
		user := old_users[0]

		if user.name == '' || user.random_id == '' {
			println('skipping empty ${user}')
			continue
		}

		new_user := User{
			username: user.name
			random_id: user.random_id
		}
		sql app.db {
			insert new_user into User
		} or {}

		new_user2 := sql app.db {
			select from User where username == username
		}!

		pkg := Package{
			name: mod.name
			description: mod.description
			url: mod.url
			nr_downloads: mod.nr_downloads
			vcs: mod.vcs
			user_id: new_user2[0].id
		}
		sql app.db {
			insert pkg into Package
		} or { continue }
	}
}
