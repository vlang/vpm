module entity

import time

@[json: 'package']
pub struct Package {
pub mut:
	id            int    @[primary; sql: serial]
	name          string @[unique]
	description   string
	documentation string
	url           string
	nr_downloads  int
	vcs           string = 'git'
	user_id       int
	author_id     int  @[json: '-']
	author        User @[sql: '-']
	stars         int
	is_flatten    bool // No need to mention author of package, example `ui`
	updated_at    time.Time = time.now()
	created_at    time.Time = time.now()
}

pub fn (p Package) format_name() string {
	return p.name
}

// short_name returns the package name without the author prefix,
// e.g. `vlua` for `abuss.vlua`.
pub fn (p Package) short_name() string {
	dot := p.name.last_index('.') or { return p.name }
	return p.name[dot + 1..]
}

// author_name returns the author prefix of the package name,
// e.g. `abuss` for `abuss.vlua`. It is empty for names without a dot,
// e.g. flattened packages like `ui`.
pub fn (p Package) author_name() string {
	dot := p.name.last_index('.') or { return '' }
	return p.name[..dot]
}

pub fn (p Package) belongs_to_user(user_id int) bool {
	return p.user_id == user_id
}
