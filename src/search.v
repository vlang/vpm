module main

import vweb
import entity

pub fn (mut app App) search(query string) vweb.Result {
	title := if query == '' { 'All Packages' } else { 'Search Results' }
	unsorted_packages := app.packages.query(query)
	packages := sort_packages(unsorted_packages) // NOTE: packages variable is used in search.html template

	return $vweb.html()
}

fn sort_packages(unsorted_packages []entity.Package) []entity.Package {
	mut packages := unsorted_packages.clone()

	packages.sort_with_compare(compare_packages)

	return packages
}

fn compare_packages(a &entity.Package, b &entity.Package) int {
	if a.stars != b.stars {
		return if a.stars > b.stars { -1 } else { 1 }
	}

	if a.downloads != b.downloads {
		return if a.downloads > b.downloads { -1 } else { 1 }
	}

	if a.updated_at != b.updated_at {
		return if a.updated_at > b.updated_at { -1 } else { 1 }
	}

	return a.name.compare(b.name)
}
