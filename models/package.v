module models

// TODO: Think more, THINK! This down here is shit!
pub interface PackageService {
	insert_package(package Package) ?Package
	get_package(id int) ?Package
	get_package_by_name(name string) ?Package
	get_package_by_author(id int) ?Package
	get_packages_with_name(like string, limit int, offset int) ?[]Package
	get_packages_sorted_by_name(limit int, offset int) ?[]Package
	get_packages_sorted_by_stars(limit int, offset int) ?[]Package
	get_packages_sorted_by_downloads(limit int, offset int) ?[]Package
	get_packages_sorted_by_last_updated(limit int, offset int) ?[]Package
	get_packages_all() ?[]Package
	update_package(package Package) ?Package
	delete_package(id int) ?Package

	insert_version(package_id int, version Version) ?Version
	get_version(id int) ?Version
	get_package_versions(package_id int) ?[]Version
	update_version(version Version) ?Version
	delete_version(id int) ?Version

	add_dependency(consumer_id int, dependency_id int) ?
	get_dependencies(consumer_id int) ?(dependencies []int)
	update_dependency(consumer_id int, from int, to int) ?
	delete_dependency(consumer_id int, dependency_id int) ?

	insert_category(category Category) ?Category
	get_category(id int) ?Category
	get_category_by_name(name string) ?Category
	update_category(category Category) ?Category
	delete_category(id int) ?Category

	insert_tag(tag Tag) ?Tag
	get_tag(id int) ?Tag
	get_tag_by_name(name string) ?Tag
	update_tag(tag Tag) ?Tag
	delete_tag(id int) ?Tag
}

// pub struct PackageInfo {
// pub:
// 	Package
// 	versions     []Version
// 	categories   []Category
// 	tags         []Tag
// }

pub struct Package {
pub:
	id           int
	author_id    int [json: authorId]

	name         string 
	description  string
	license      string
	vcs          string
	repo_url     string [json: repoUrl]

	stars        int
	nr_downloads int [json: downloads]
	
	created_at time.Time [json: createdAt]
	updated_at time.Time [json: updatedAt]
}

pub fn (package Package) get_old_package() OldPackage {
	return OldPackage{
		id: package.id
		name: package.name
		url: package.repo_url
		nr_downloads: package.nr_downloads
		vcs: package.vcs
	}
}

pub struct Version {
pub:
	id          int
	package_id  int [json: packageId]

	name        string
	url         string // url of commit or something, needed for `v install`
	release_url string [json: releaseUrl] // mostly for users, like github release page
	nr_downloads int [json: downloads]

	// dependencies []Dependency
	date        time.Time
}

pub struct Dependency {
pub:
	id      int
	version_id string [json: versionId]
}

pub struct Category {
pub:
	id   int
	name string
	nr_packages int [json: packages]
}

pub struct Tag {
pub:
	id          int
	name        string
	nr_packages int [json: packages]
}

pub struct OldPackage {
pub:
	id           int
	name         string
	vcs          string
	url          string
	nr_downloads int [json: downloads]
}