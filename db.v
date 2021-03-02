module main

fn (mut app App) create_table(name string, fields []string) {
	app.db.exec('create table if not exists `$name` (' + fields.join(',') + ')')
}

fn (mut app App) create_tables() {
	app.create_table('Package', [
		'id integer primary key',
		'author_id integer default -1',
		'name text default ""',
		'version text default "0.0.1"',
		'description text default ""',
		'tags text default ""',
		'dependencies text default ""',
		'license text default ""',
		'repo_url text default ""',
		'nr_downloads integer default 0',
		'foreign key (author_id) references User(id)',
	])
	app.create_table('User', [
		'id integer primary key',
		'name text default ""',
		'username text default ""',
		'is_blocked int default 0',
		'is_admin int default 0',
		'avatar text default ""',
		'login_attempts integer default 0',
	])
	app.create_table('Token', [
		'id integer primary key',
		'user_id integer default 0',
		"value text defaut ''",
		'ip text default ""',
	])
}
