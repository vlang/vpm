module package

import entity { Package }

enum PackageSortOrder {
	stars
	downloads
	updated_at
}

type SortFunction = fn (a &Package, b &Package) int

struct PackageSort {
	order PackageSortOrder
	desc  int
}

fn PackageSort.new(sort string) PackageSort {
	return PackageSort{
		order: match sort.trim(' -') {
			'stars' { PackageSortOrder.stars }
			'downloads' { PackageSortOrder.downloads }
			'updated_at' { PackageSortOrder.updated_at }
			else { PackageSortOrder.downloads }
		}
		desc: if sort.starts_with('-') || sort.len == 0 { -1 } else { 1 }
	}
}

fn cmp(a int, b int) int {
	if a < b {
		return -1
	}
	if a > b {
		return 1
	}
	return 0
}

fn (s PackageSort) get_param(p &Package) int {
	match s.order {
		.stars { return p.stars }
		.downloads { return p.nr_downloads }
		.updated_at { return int(p.updated_at.unix_time()) }
	}
}

fn (s PackageSort) compare(a &Package, b &Package) int {
	return cmp(s.get_param(a), s.get_param(b)) * s.desc
}
