module repository

const (
	access_tokens_fields = "user_id, value, ip, created_at"
	categories_fields = "id, slug, name"
	gh_tokens_fields = "user_id, token"
	packages_fields = "id, author_id, name, description, license, repo_url, stars, downloads, downloaded_at, created_at, updated_at"
	tags_fields = "id, slug, name"
	users_fields = "id, github_id, login, name, avatar_url"
	versions_fields = "id, package_id, tag, downloads, commit_hash, release_url, release_date"
)

const (
	access_tokens_table          = 'vpm.access_tokens'
	admins_table          = 'vpm.admins'
	bans_table          = 'vpm.bans'
	categories_table          = 'vpm.categories'
	dependencies_table        = 'vpm.dependencies'
	gh_tokens_table          = 'vpm.gh_tokens'
	package_to_category_table = 'vpm.package_to_category'
	package_to_tag_table      = 'vpm.package_to_tag'
	packages_table            = 'vpm.packages'
	tags_table                = 'vpm.tags'
	users_table               = 'vpm.users'
	versions_table            = 'vpm.versions'
)

const (
	most_downloadable_view     = 'vpm.most_downloadable_packages'
	most_recent_downloads_view = 'vpm.most_recent_downloads'
	new_packages_view          = 'vpm.new_packages'
	popular_categories_view    = 'vpm.popular_categories'
	popular_tags_view          = 'vpm.popular_tags'
	recently_updated_view      = 'vpm.recently_updated_packages'
)
