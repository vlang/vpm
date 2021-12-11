// Hey, vpm.github implements only specific for vpm parts of api, so if your want to use it
// It will take a lot of work to make it universal ^-^
module github

import net.http
import json

pub const api = 'https://api.github.com'

pub fn get_repo_by_id(id int) ?Repository {
	res := http.fetch(method: .get, url: github.api + '/repositories/$id', user_agent: 'vpm') ?
	return json.decode(Repository, res.text) or { return err }
}
