module main

fn (mut app App) create_table(name string, fields []string) {
	app.db.exec('create table if not exists `$name` (' + fields.join(',') + ')')
}

fn (mut app App) create_tables() {
	app.create_table('Mod', [
		'id integer primary key',
		'name text default ""',
		'version text default "0.0.1"',
		'description text default ""',
		'tags text default ""',
		'dependencies text default ""',
		'license text default ""',
		'repo_url text default ""',
		'url text default ""',
		'nr_downloads int default 0',
		'vcs text default "git"',
	])
	app.create_table('User', [
		'id integer primary key',
		'name text default ""',
		'username text default ""',
		'is_admin int default 0',
		'avatar text default ""',
		'login_attempts int default 0',
	])
}