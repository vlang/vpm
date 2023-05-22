module entity

import time
import net.http

[json: 'package']
pub struct Package {
pub mut:
	id                      int       [primary; sql: serial]
	name                    string    [unique]
	short_description       string
	full_description        ?string
	readme_file_content_url ?string
	documentation           string
	url                     string
	nr_downloads            int
	vcs                     string = 'git'
	user_id                 int
	author                  User      [fkey: 'id']
	stars                   int
	is_flatten              bool // No need to mention author of package, example `ui`
	updated_at              time.Time = time.now()
	created_at              time.Time = time.now()
}

pub fn (p Package) format_name() string {
	return p.name
}

pub fn (p Package) belongs_to_user(user_id int) bool {
	return p.user_id == user_id
}

// get_full_description Returns content of README file if it exists, otherwise returns manually provided description (if any).
// NOTE: This function is used in `package.html` template
pub fn (p Package) get_full_description() string {
	if p.readme_file_content_url == none {
		return p.full_description or { '' }
	}

	readme_file_content_response := http.get(readme_file_content_url) or {
		return error('Failed to fetch README file content from ${readme_file_content_url}:\n${err}')
	}

	return readme_file_content_response.body
}
