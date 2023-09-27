module entity

import time

[json: 'category']
pub struct Category {
pub mut:
	id int [primary; sql: serial]
	// For paths `/search?category=slug`
	slug string [unique]
	// Packages count
	packages int

	name        string [unique]
	description string

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}

[json: 'category_to_package']
pub struct CategoryPackage {
pub mut:
	id          int [primary; sql: serial]
	category_id int [fkey: 'Category']
	package_id  int [fkey: 'Package']
}
