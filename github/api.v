// Hey, vpm.github implements only specific for vpm parts of api, so if your want to use it
// It will take a lot of work to make it universal ^-^
module github

import net.http
import x.json2

pub const api = 'https://api.github.com'

// Request repo by id
pub fn get_repo_by_id(id int) ?Repository {
	res := http.fetch(method: .get, url: github.api + '/repositories/$id', user_agent: 'vpm')?
	return json2.decode<Repository>(res.body) or { return err }
}
