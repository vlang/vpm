module vsqlite

import vpm.models

fn create_table(db sqlite.DB, name string, fields []string) ? {
	db.exec_none('CREATE TABLE IF NOT EXISTS `$name` (' + fields.join(',') + ');') ?
}

fn add_q(text string) string {
	return "'" + text + "'"
}

fn package_to_row(package models.Package) string {
	return '(' + package.author_id.str() + ', ' + 
		add_q(package.name) + ', ' +
		add_q(package.description) + ', ' +
		add_q(package.license) + ', ' +
		add_q(package.vcs) + ', ' +
		add_q(package.repo_url) + ', ' +
		package.stars.str() + ', ' +
		package.nr_downloads.str() + ', ' +
		package.last_updated + ')'
}

fn package_from_row(row sqlite.Row) ?models.Package {
	mut cursor := 0
	if row.vals.len < 10 {
		panic("Can't get package from row, what comes is: $row.vals")
	} 
	return {
		id: row.vals[cursor++].int()
		author_id: row.vals[cursor++].int()

		name: row.vals[cursor++]
		description: row.vals[cursor++]
		license: row.vals[cursor++]
		vcs: row.vals[cursor++]
		repo_url: row.vals[cursor++]

		stars: row.vals[cursor++].int()
		nr_downloads: row.vals[cursor++].int()
		last_updated: time.unix(row.vals[cursor++].int())
	}
}

fn packages_from_rows(rows []sqlite.Row) ?[]models.Package {
	mut packages := []models.Package{}
	for row in rows {
		packages << package_from_row(row) ?
	}
	return packages
}

fn version_to_row(version models.Version) string {
	return '(' + version.package_id + ', ' +
		add_q(version.name) + ', ' +
		add_q(version.url) + ', ' +
		add_q(version.release_url) + ', ' +
		version.nr_downloads.str() + ', ' + 
		version.date.unix_time().str() + ')'
}

fn version_from_row(row sqlite.Row) ?models.Version {
	mut cursor := 0
	if row.vals.len < 6 {
		panic("Can't get version from row, what comes is: $row.vals")
	}
	return {
		id: row.vals[cursor++].int()
		package_id: row.vals[cursor++].int()
		name: row.vals[cursor++]
		url: row.vals[cursor++]
		release_url: row.vals[cursor++]
		nr_downloads: row.vals[cursor++].int()
		date: time.unix(row.vals[cursor++].int())
	}
}

fn versions_from_rows(rows []sqlite.Row) ?[]models.Version {
	mut vrss := []models.Version{}
	for row in rows {
		vrss << version_from_row(row) ?
	}
	return vrss
}

fn category_from_row(row sqlite.Row) models.Category {
	mut cursor := 0
	if row.vals.len < 3 {
		panic("Can't get category/tag from row, what comes is: $row.vals")
	}
	return {
		id: row.vals[cursor++].int()
		name: row.vals[cursor++]
		nr_packages: row.vals[cursor++].int()
	}
}

fn user_to_row(user models.User) string {
	return '(' + add_q(user.username) + ', ' +
		add_q(user.avatar_url) + ', ' +
		add_q(user.is_blocked.str()) + ', ' +
		add_q(user.is_admin.str()) + ', ' +
		user.login_attempts.str() + ')'
}

fn user_from_row(row sqlite.Row) ?models.User {
	mut cursor := 0
	if row.vals.len < 6 {
		panic("Can't get user from row, what comes is: $row.vals")
	}
	return {
		id: row.vals[cursor++].int()
		username: row.vals[cursor++]
		avatar_url: row.vals[cursor++]
		is_blocked: row.vals[cursor++].bool()
		is_admin: row.vals[cursor++].bool()
		login_attempts: row.vals[cursor++].int()
	}
}