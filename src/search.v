module main

import vweb
import entity { Package }

['/search']
pub fn (mut app App) search() vweb.Result {
	query := app.query['q']
	category := app.query['category']
	title := if query == '' { 'All Packages' } else { 'Search Results' }
	unsorted_packages := app.packages().query(query)
	mut packages := sort_packages(unsorted_packages) // NOTE: packages variable is used in search.html template

	if category.len > 0 {
		if cpkgs := app.packages().get_category_packages(category) {
			ids := cpkgs.map(it.id)
			packages = packages.filter(it.id in ids)
		}
	}

	return $vweb.html()
}

fn sort_packages(unsorted_packages []Package) []Package {
	mut packages := unsorted_packages.clone()

	packages.sort_with_compare(compare_packages)

	return packages
}

fn compare_packages(a &Package, b &Package) int {
	if a.stars != b.stars {
		return if a.stars > b.stars { -1 } else { 1 }
	}

	if a.nr_downloads != b.nr_downloads {
		return if a.nr_downloads > b.nr_downloads { -1 } else { 1 }
	}

	if a.updated_at != b.updated_at {
		return if a.updated_at > b.updated_at { -1 } else { 1 }
	}

	return a.name.compare(b.name)
}
