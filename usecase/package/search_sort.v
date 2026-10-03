module package

import time
import entity { Package }

enum PackageSortOrder {
	stars
	downloads
	updated_at
	created_at
	// `popularity` is `entity.Package.score()` — combines downloads, stars,
	// created_at and updated_at into one blended ranking.
	popularity
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
			'created_at' { PackageSortOrder.created_at }
			'popularity' { PackageSortOrder.popularity }
			else { PackageSortOrder.popularity }
		}
		desc:  if sort.starts_with('-') || sort.len == 0 { -1 } else { 1 }
	}
}

fn cmp(a i64, b i64) int {
	if a < b {
		return -1
	}
	if a > b {
		return 1
	}
	return 0
}

fn (s PackageSort) get_param(p &Package) i64 {
	match s.order {
		.stars {
			return i64(p.stars)
		}
		.downloads {
			return i64(p.nr_downloads)
		}
		.updated_at {
			return p.updated_at.unix()
		}
		.created_at {
			return p.created_at.unix()
		}
		.popularity {
			return p.score(time.now())
		}
	}
}

fn (s PackageSort) compare(a &Package, b &Package) int {
	return cmp(s.get_param(a), s.get_param(b)) * s.desc
}
