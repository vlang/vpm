module repository

const (
	categories_table          = 'category'
	packages_table            = 'package'
	tags_table                = 'tag'
	tokens_table              = 'token'
	users_table               = 'user'
	versions_table            = 'version'

	dependencies_table        = 'dependency'
	package_to_category_table = 'package_to_category'
	package_to_tag_table      = 'package_to_tag'
)

const (
	most_downloadable_view = 'most_downloadable_packages'
	most_recent_downloads_view = 'most_recent_downloads'
	new_packages_view = 'new_packages'
	popular_categories_view = 'popular_categories'
	popular_tags_view = 'popular_tags'
	recently_updated_view = 'recently_updated_packages'
)
