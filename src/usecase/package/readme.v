module package

import net.http
import net.urllib
import x.json2

pub fn (u UseCase) get_package_markdown(name string) !string {
	pkg := u.packages.get(name)!

	url := urllib.parse(pkg.url)!

	// Getting default git branch
	bb := 'https://api.github.com/repos${url.path}'
	println(bb)
	api_repo := http.get(bb)!
	if api_repo.status() != http.Status.ok {
		return error('repo status is not 200, real ${api_repo.status()}')
	}
	body := json2.raw_decode(api_repo.body)!
	branch := body.as_map()['default_branch'] or { json2.Any('main') }

	// Getting raw readme markdown
	aa := 'https://raw.githubusercontent.com${url.path}/${branch}/README.md'
	println(aa)
	readme := http.get(aa)!
	if readme.status() != http.Status.ok {
		return error('readme status is not 200, real ${api_repo.status()}')
	}

	return readme.body
}

fn format_raw_content_url(user string, repo string, branch string, file string) string {
	return 'https://raw.githubusercontent.com/${user}/${repo}/${branch}/${file}'
}
