module package

import net.http

// https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes
// each possible path a readme can be read from, in descending order of priority
const readme_paths = [
	'.github/',
	'',
	'docs/',
]

// common readme file cases
const readme_cases = ['README', 'readme']

// vpm can only render markdown and plaintext, but github supports a large amount of formats:
// https://stackoverflow.com/a/41112364
const readme_exts = [
	'.md',
	'.txt',
	'', // readmes with no file extension are plaintext by default
]

const valid_readme_paths = get_possible_readme_paths()

fn get_possible_readme_paths() []string {
	mut paths := []string{}
	for path in readme_paths {
		for case in readme_cases {
			for ext in readme_exts {
				paths << '${path}${case}${ext}'
			}
		}
	}
	return paths
}

// fetch_markdown reads the README from the repository's default branch.
pub fn fetch_markdown(repo_url string) !string {
	repository := parse_repo_url(repo_url)!
	if repository.owner == '' || repository.repo_name == '' {
		return error('invalid repository URL')
	}

	for path in valid_readme_paths {
		readme_url := 'https://raw.githubusercontent.com/${repository.owner}/${repository.repo_name}/HEAD/${path}'
		readme := http.get(readme_url)!
		if readme.status() == http.Status.ok {
			return readme.body
		}
		if readme.status() != .not_found {
			return error('README request returned HTTP ${readme.status_code}')
		}
	}

	return ''
}
