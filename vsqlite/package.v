module vsqlite

import sqlite
import vpm.models

pub struct PackageService {
	db sqlite.DB
}

pub fn new_package_service(db sqlite.DB) ?PackageService {
	db.exec_none("PRAGMA foreign_keys = ON;") ?

	// TABLES AND RELATIONS
	// TODO: Migrations
	
	create_table(db, 'package', [
		'id INT PRIMARY KEY AUTOINCREMENT',
		'author_id INT NOT NULL',

		'name TEXT NOT NULL CHECK (name is null or length(name) <= 100)',
		'description TEXT DEFAULT "" CHECK (length(description) <= 280)',
		'license TEXT DEFAULT ""',
		'vcs TEXT DEFAULT "git"',
		'repo_url TEXT NOT NULL',

		'stars INT DEFAULT 0',
		'nr_downloads INT DEFAULT 0',
		'last_updated DATETIME DEFAULT 0',

		'FOREIGN KEY(author_id) REFERENCES user(id)',
	]) ?

	create_table(db, 'version', [
		'id INT PRIMARY KEY AUTOINCREMENT',
		'package_id INT NOT NULL',

		'name TEXT NOT NULL',
		'url TEXT NOT NULL',
		'release_url TEXT DEFAULT ""',
		'nr_downloads INT DEFAULT 0',
		'date DATETIME DEFAULT 0',

		'FOREIGN KEY(package_id) REFERENCES package(id)',
	]) ?

	create_table(db, 'version_to_dependency' [
		'consumer_id INT NOT NULL',
		'dependency_id INT NOT NULL',
		'FOREIGN KEY(consumer_id) REFERENCES version(id)',
		'FOREIGN KEY(dependency_id) REFERENCES version(id)',
		'PRIMARY KEY(consumer_id, dependency_id)',
		'CHECK (consumer_id <> dependency_id)'
	]) ?

	create_table(db, 'package_to_category' [
		'package_id INT',
		'category_id INT ',
		'FOREIGN KEY(package_id) REFERENCES package(id)',
		'FOREIGN KEY(category_id) REFERENCES category(id)',
	]) ?

	create_table(db, 'category', [
		'id INT PRIMARY KEY AUTOINCREMENT',
		'name TEXT NOT NULL',
		'nr_packages INT NOT NULL',
	]) ?

	create_table(db, 'package_to_tag' [
		'package_id INT',
		'tag_id INT ',
		'FOREIGN KEY(package_id) REFERENCES package(id)',
		'FOREIGN KEY(tag_id) REFERENCES tag(id)',
	]) ?

	create_table(db, 'tag', [
		'id INT PRIMARY KEY AUTOINCREMENT',
		'name TEXT NOT NULL',
		'nr_packages INT NOT NULL',
	]) ?

	// TRIGGERS

	db.exec_none("
		CREATE TRIGGER update_package_nr_downloads
			AFTER UPDATE ON version
			WHEN old.nr_downloads <> new.nr_downloads
		BEGIN
			UPDATE package
			SET nr_downloads = nr_downloads + (new.nr_downloads - old.nr_downloads)
			WHERE id = new.package_id;
		END;
	") ?

	db.exec_none("
		CREATE TRIGGER update_category_nr_packages
			AFTER INSERT ON package_to_category
		BEGIN
			UPDATE category
			SET nr_packages = nr_packages + 1
			WHERE id = new.category_id;
		END;
	") ?

	db.exec_none("
		CREATE TRIGGER update_category_nr_packages
			AFTER DELETE ON package_to_category
		BEGIN
			UPDATE category
			SET nr_packages = nr_packages - 1
			WHERE id = new.category_id;
		END;
	") ?

	db.exec_none("
		CREATE TRIGGER update_tag_nr_packages
			AFTER INSERT ON package_to_tag
		BEGIN
			UPDATE tag
			SET nr_packages = nr_packages + 1
			WHERE id = new.tag_id;
		END;
	") ?

	db.exec_none("
		CREATE TRIGGER update_tag_nr_packages
			AFTER DELETE ON package_to_tag
		BEGIN
			UPDATE tag
			SET nr_packages = nr_packages - 1
			WHERE id = new.tag_id;
		END;
	") ?
	
	return PackageService{
		db: db
	}
}

pub fn (s PackageService) insert_package(package models.Package) ?models.Package {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	s.db.exec_one("INSERT INTO package ("+
		"author_id," + 
		"name, description, license, vcs, repo_url," +
		"stars, nr_downloads, last_updated"+
		") VALUES " + package_to_row(package) + ";"
	) ?
	return s.get_package(id) ?
}

pub fn (s PackageService) get_package(id int) ?models.Package {
	// Doing it by hands because we need control over errors
	row := s.db.exec_one('SELECT * FROM package WHERE id = $id LIMIT 1;') ?
	return package_from_row(row) ?
}

pub fn (s PackageService) get_package_by_name(name string) ?models.Package {
	// Doing it by hands because we need control over errors
	row := s.db.exec_one('SELECT * FROM package WHERE name = $name LIMIT 1;') ?
	return package_from_row(row) ?
}

pub fn (s PackageService) get_packages_by_author(id int) ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec('SELECT * FROM package WHERE author_id = $id LIMIT 1;') ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) get_packages_with_name(like string, limit int, offset int) ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec("SELECT * FROM package LIKE '%$like%' ORDER BY name DESC LIMIT $limit OFFSET $offset;") ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) get_packages_sorted_by_name(limit int, offset int) ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec('SELECT * FROM package ORDER BY name DESC LIMIT $limit OFFSET $offset;') ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) get_packages_sorted_by_stars(limit int, offset int) ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec('SELECT * FROM package ORDER BY stars DESC LIMIT $limit OFFSET $offset;') ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) get_packages_sorted_by_downloads(limit int, offset int) ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec('SELECT * FROM package ORDER BY nr_downloads DESC LIMIT $limit OFFSET $offset;') ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) get_packages_sorted_by_last_updated(limit int, offset int) ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec('SELECT * FROM package ORDER BY last_updated DESC LIMIT $limit OFFSET $offset;') ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) get_packages_all() ?[]models.Package {
	// Doing it by hands because we need control over errors
	rows := s.db.exec('SELECT * FROM package;') ?
	return packages_from_rows(rows) ?
}

pub fn (s PackageService) update_package(package models.Package) ?models.Package {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	s.db.exec_one('UPDATE package SET '+
		"name = '$package.name', " +
		"description = '$package.description', " + 
		"license = '$package.license', " +
		"vcs = '$package.vcs', " + 
		"repo_url = '$package.repo_url', " + 
		"stars = $package.stars, " + 
		"nr_downloads = $package.nr_downloads, " +
		"last_updated = ${package.last_updated.unix_time()} " +
		"WHERE id = $package.id;"
	) ?
	return s.get_package(id) ?
}

pub fn (s PackageService) delete_package(id int) ?models.Package {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	pkg := s.get_package(id) ?
	s.db.exec_none('DELETE FROM package WHERE id = $id;') ?
	return pkg
}

pub fn (s PackageService) insert_version(package_id int, version models.Version) ?models.Version {
	s.db.exec_one("INSERT INTO version ("+
		"package_id, name, url, release_url, nr_downloads, date" + 
		") VALUES " + version_to_row(package) + ";"
	) ?
	return s.get_version(version.id) ?
}

pub fn (s PackageService) get_version(id int) ?models.Version {
	// Doing it by hands because we need control over errors
	row := s.db.exec_one('SELECT * FROM version WHERE id = $id LIMIT 1;') ?
	ver := version_from_row(row) ?
	return {
		...ver
		dependencies
	}
}

pub fn (s PackageService) get_package_versions(package_id int) ?[]models.Version {
	// Doing it by hands because we need control over errors
	rows, _ := s.db.exec('SELECT * FROM version WHERE package_id = $package_id;') ?
	ver := versions_from_rows(rows) ?
	return {
		...ver
		dependencies
	}
}

pub fn (s PackageService) update_version(version models.Version) ?models.Version {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	s.db.exec_one('UPDATE version SET '+
		"name = '$version.name', " +
		"url = '$version.repo_url', " + 
		"release_url = '$version.release_url', " + 
		"nr_downloads = $version.nr_downloads, " +
		"date = ${version.date.unix_time()} " +
		"WHERE id = $version.id;"
	) ?
	return s.get_version(id) ?
}

pub fn (s PackageService) delete_package(id int) ?models.Version {
	// Doing it by hands because we need control over errors
	// TODO: Add RETURNING https://sqlite.org/lang_returning.html then ubuntu updates it's sqlite libs to 3.35.0
	vrs := s.get_version(id) ?
	s.db.exec_none('DELETE FROM version WHERE id = $id;') ?
	return vrs
}

pub fn (s PackageService) add_dependency(consumer_id int, dependency_id int) ? {
	s.db.exec_one("INSERT INTO version_to_dependency "+
		"(consumer_id, dependency_id) " + 
		"VALUES ($consumer_id, $dependency_id);"
	) ?
}

pub fn (s PackageService) get_dependencies(consumer_id int) ?(dependencies []int) {
	rows, _ := s.db.exec("SELECT dependency_id FROM version_to_dependency "+
		"WHERE consumer_id = $consumer_id;"
	) ?
	return rows.vals
}

pub fn (s PackageService) update_dependency(consumer_id int, from int, to int) ? {
	s.db.exec_one("UPDATE version_to_dependency SET " +
		"dependency_id = $to"
		"WHERE consumer_id = $consumer_id AND dependency_id = $from LIMIT 1;"
	) ?
}

pub fn (s PackageService) delete_dependency(consumer_id int, dependency_id int) ? {
	s.db.exec_one("DELETE FROM version_to_dependency " +
		"WHERE consumer_id = $consumer_id AND dependency_id = $dependency_id;"
	) ?
}

pub fn (s PackageService) insert_category(category models.Category) ?models.Category {
	s.db.exec_one("INSERT INTO category "+
		"(name, nr_packages) " + 
		"VALUES ('$category.name', $category.nr_packages);"
	) ?
}

pub fn (s PackageService) get_category(id int) ?models.Category {
	row := s.db.exec_one("SELECT * FROM category WHERE id = $id LIMIT 1;") ?
	return category_from_row() ?
}

pub fn (s PackageService) get_category_by_name(name string) ?models.Category {
	row := s.db.exec_one("SELECT * FROM category WHERE name = '$name' LIMIT 1;") ?
	return category_from_row() ?
}

pub fn (s PackageService) update_category(category models.Category) ?models.Category {
	s.db.exec_one("UPDATE category SET " +
		"name = '$category.name', " +
		"nr_packages = $category.nr_packages " +
		"WHERE id = $id LIMIT 1;"
	) ?
	return s.get_category(category.id) ?
}

pub fn (s PackageService) delete_category(id int) ?models.Category {
	ctg := s.get_category(id) ?
	s.db.exec_one("DELETE FROM category WHERE id = $id;") ?
	return ctg
}

pub fn (s PackageService) insert_tag(tag models.Tag) ?models.Tag {
	s.db.exec_one("INSERT INTO tag "+
		"(name, nr_packages) " + 
		"VALUES ('$tag.name', $tag.nr_packages);"
	) ?
}

pub fn (s PackageService) get_tag(id int) ?models.Tag {
	row := s.db.exec_one("SELECT * FROM tag WHERE id = $id LIMIT 1;") ?
	// it's intended, category and tag has the same fields
	return category_from_row() ?
}

pub fn (s PackageService) get_tag_by_name(name string) ?models.Tag {
	row := s.db.exec_one("SELECT * FROM tag WHERE name = '$name' LIMIT 1;") ?
	// it's intended, category and tag has the same fields
	return category_from_row() ?
}

pub fn (s PackageService) update_tag(tag models.Tag) ?models.Tag {
	s.db.exec_one("UPDATE tag SET " +
		"name = '$tag.name', " +
		"nr_packages = $tag.nr_packages " +
		"WHERE id = $id LIMIT 1;"
	) ?
	return s.get_tag(category.id) ?
}

pub fn (s PackageService) delete_tag(id int) ?models.Tag {
	ctg := s.get_tag(id) ?
	s.db.exec_one("DELETE FROM tag WHERE id = $id;") ?
	return ctg
}