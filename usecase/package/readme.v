module package

import net.http
import net.urllib
import x.json2

// https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes
// each possible path a readme can be read from, in descending order of priority
const readme_paths = [
	'/.github/',
	'/',
	'/docs/',
]

// common readme file cases
const readme_cases = ['README', 'readme']

// vpm can only render markdown and plaintext, but github supports a large amount of formats:
// https://stackoverflow.com/a/41112364
const readme_exts = [
	'md',
	'txt',
	'', // readmes with no file extension are plaintext by default
]

const valid_readme_paths = get_possible_readme_paths()

fn get_possible_readme_paths() []string {
	mut paths := []string{}
	for path in readme_paths {
		for case in readme_cases {
			for ext in readme_exts {
				paths << '${path}/${case}.${ext}'
			}
		}
	}
	return paths
}

pub fn (u UseCase) get_package_markdown(name string) !string {
	pkg := u.packages.get(name)!

	url := urllib.parse(pkg.url)!

	// Getting default git branch
	bb := 'https://api.github.com/repos${url.path}'
	api_repo := http.get(bb)!
	if api_repo.status() != http.Status.ok {
		return error('repo status is not 200, real ${api_repo.status()}')
	}
	body := json2.decode[json2.Any](api_repo.body)!
	branch := body.as_map()['default_branch'] or { json2.Any('main') }

	// Getting raw readme markdown
	for path in valid_readme_paths {
		readme_url := 'https://raw.githubusercontent.com${url.path}/${branch}/${path}'
		readme := http.get(readme_url)!
		if readme.status() == http.Status.ok {
			return readme.body
		}
	}

	// If no readme is found, just return blank
	return ''
}
