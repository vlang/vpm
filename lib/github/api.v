// Hey, vpm.github implements only specific for vpm parts of api, so if your want to use it - write your own ^-^
module github

import net.http
import x.json2

pub const api = 'https://api.github.com'

// Request repo by id
pub fn get_repo_by_id(id int) !Repository {
	res := http.fetch(method: .get, url: github.api + '/repositories/${id}', user_agent: 'vpm')!
	if res.status() != .ok {
		return error('status not ok: ${res.status()}, ${res.body}')
	}

	return json2.decode[Repository](res.body)
}

pub struct Client {
	authorization string
}

pub fn new_client(access_token string) Client {
	return Client{
		authorization: 'Bearer ${access_token}'
	}
}

pub fn (c Client) auth_header() http.HeaderConfig {
	return http.HeaderConfig{
		key: .authorization
		value: c.authorization
	}
}

pub fn (c Client) current_user() !User {
	res := http.fetch(
		method: .get
		header: http.new_header(c.auth_header())
		url: github.api + '/user'
	)!
	if res.status() != .ok {
		return error('status not ok: ${res.status()}, ${res.body}')
	}

	return json2.decode[User](res.body)
}
