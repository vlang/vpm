module entity

import time

[json: 'package']
pub struct Package {
pub mut:
	id            int       [primary; sql: serial]
	name          string    [unique]
	description   string
	documentation string
	url           string
	downloads     int
	vcs           string = 'git'
	user_id       int
	author        User      [fkey: 'id']
	stars         int
	is_flatten    bool // No need to mention author of package, example `ui`
	updated_at    time.Time = time.now()
	created_at    time.Time = time.now()
}

pub struct FullPackage {
	Package
pub mut:
	author     User
	categories []Category
}

pub fn (package FullPackage) format_name() string {
	return if package.is_flatten {
		package.name
	} else {
		'${package.author.username}.${package.name}'
	}
}

pub struct PackagesView {
pub mut:
	total_count               int
	new_packages              []FullPackage
	most_downloaded_packages  []FullPackage
	recently_updated_packages []FullPackage
}

// Backward compatibility for V <=0.3
pub struct OldPackage {
pub mut:
	id           int
	name         string
	vcs          string = 'git'
	url          string
	nr_downloads int
}

pub fn (p Package) format_name() string {
	return p.name
}

pub fn (p Package) belongs_to_user(user_id int) bool {
	return p.user_id == user_id
}
