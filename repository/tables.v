module repository

const (
	access_tokens_fields = 'user_id, value, ip, created_at'
	gh_tokens_fields     = 'user_id, token'
	keywords_fields      = 'id, slug, name'
	packages_fields      = 'id, author_id, name, description, license, repo_url, stars, downloads, downloaded_at, created_at, updated_at'
	tags_fields          = 'id, slug, name'
	users_fields         = 'id, github_id, login, name, avatar_url'
	versions_fields      = 'id, package_id, tag, downloads, commit_hash, release_url, release_date'
)

const (
	access_tokens_table    = 'access_tokens'
	gh_tokens_table        = 'gh_tokens'
	keywords_table         = 'keywords'
	packages_table         = 'packages'
	users_table            = 'users'
	versions_table         = 'versions'

	dependencies_table     = 'version_dependencies'
	package_keywords_table = 'package_keywords'
)

const (
	most_downloadable_view = 'most_downloadable_packages'
)
