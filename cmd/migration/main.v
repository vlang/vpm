module main

import flag
import os
import strconv
import pg
import app.config

const (
	config_file = './config.toml'
)

const (
	default_migrations_table = 'schema_migrations'
)

fn main() {
	mut latest_version := false

	mut fp := flag.new_flag_parser(os.args)
	fp.application('vpm migration tool')
	fp.version('v0.1.0')
	fp.limit_free_args_to_exactly(1) ?
	fp.description('Stupidly simple migration tool.')
	fp.skip_executable()
	fp.arguments_description('migrations folder')
	forced_version := fp.int_opt('version', `v`, 'force specific version') or {
		latest_version = true
		0
	}
	// dbname := fp.string('dbname', 'd', '', 'postgres database name')
	args := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	println('Checking migrations...')
	up, down := migrations(args.first()) ?
	println('Reading configuration...')
	cfg := config.parse_file(config_file) ?
	println('Connecting to db...')
	mut db := pg.connect(pg.Config{
		host: cfg.pg.host
		port: cfg.pg.port
		user: cfg.pg.user
		password: cfg.pg.password
		dbname: cfg.pg.db_name
	}) ?
	version := current_version(mut db, default_migrations_table) ?
}

struct Migration {
	version i64

	path    string
	content string
}

fn migrations(folder_path string) ?([]Migration, []Migration) {
	paths := os.ls(folder_path) ?

	mut up := []Migration{}
	mut down := []Migration{}
	for path in paths {
		idx := os.file_name(path).index_any('_-.')
		if idx == -1 {
			continue
		}

		version := strconv.parse_int(path[..idx], 10, 64) ?

		ext := os.file_ext(path)
		if ext.starts_with('up') {
			up << Migration{
				version: version
				path: path
				content: os.read_file(path) ?
			}
		} else if ext.starts_with('down') {
			down << Migration{
				version: version
				path: path
				content: os.read_file(path) ?
			}
		}
	}

	up.sort(a.version > b.version)
	down.sort(a.version > b.version)

	// TODO: Check latest version, do smth

	return up, down
}

fn current_version(mut db pg.DB, migrations_table string) ?int {
	return db.q_int('SELECT version FROM $migrations_table;')
}
