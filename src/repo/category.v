module repo

import orm
import arrays
import entity { Category, CategoryPackage, Package }

const basic_categories = [
	Category{
		slug: 'cli'
		name: 'CLI'
		description: 'Argument parsers, line-editing, or output coloring and formatting.'
	},
	Category{
		slug: 'web'
		name: 'Web'
		description: 'Routing, HTTP, Websocket, SSE'
	},
	Category{
		slug: 'networking'
		name: 'Networking'
		description: 'Network protocols such as FTP, HTTP, or SSH, or lower-level TCP or UDP.'
	},
	Category{
		slug: 'gamedev'
		name: 'Gamedev'
		description: 'Engines and tools for creating games.'
	},
	Category{
		slug: 'rendering'
		name: 'Rendering'
		description: 'Real-time or offline rendering of 2D or 3D graphics, usually on a GPU.'
	},
	Category{
		slug: 'graphics'
		name: 'Graphics'
		description: "APIs Direct access to the hardware's or the operating system's rendering capabilities."
	},
	Category{
		slug: 'databases'
		name: 'Databases'
		description: 'Database interfaces, implementations and related.'
	},
	Category{
		slug: 'text-processing'
		name: 'Text processing'
		description: 'Parsers, processors, serialization, much stuff to do with text.'
	},
	Category{
		slug: 'visualization'
		name: 'Visualization'
		description: 'Plotting and graphing for data.'
	},
	Category{
		slug: 'gui'
		name: 'GUI'
		description: 'Graphical user interface.'
	},
	Category{
		slug: 'os'
		name: 'OS'
		description: 'APIs for interacting with OS and other platform specific tools.'
	},
	Category{
		slug: 'audio'
		name: 'Audio'
		description: 'Record, output or process audio.'
	},
]

pub struct CategoryRepo {
mut:
	db orm.Connection [required]
}

pub fn migrate_categories(db orm.Connection) ! {
	sql db {
		create table Category
		create table CategoryPackage
	}!

	existing_categories := sql db {
		select from Category
	}!

	existing_slugs := existing_categories.map(it.slug)

	for category in repo.basic_categories {
		if category.slug in existing_slugs {
			sql db {
				update Category set name = category.name, description = category.description
				where slug == category.slug
			}!
		} else {
			sql db {
				insert category into Category
			}!
		}
	}
}

pub fn categories(db orm.Connection) CategoryRepo {
	return CategoryRepo{
		db: db
	}
}

pub fn (r CategoryRepo) get_all() ![]Category {
	return sql r.db {
		select from Category
	}!
}

pub fn (r CategoryRepo) get_category_packages(category_id int) ![]Package {
	c2p := sql r.db {
		select from CategoryPackage where category_id == category_id
	}!

	pkgs := arrays.flatten(c2p.map(sql r.db {
		select from Package where id == it.package_id
	}!))

	return pkgs
}
