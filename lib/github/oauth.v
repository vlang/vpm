module github

import net.http
import net.urllib
import x.json2
import lib.json2 as ju

pub struct OAuthLink {
pub:
	client_id string [required]
	// The URL in your application where users will be sent after authorization. See details below about redirect urls.
	redirect_uri string
	// Suggests a specific account to use for signing in and authorizing the app.
	login string
	// A space-delimited list of scopes. If not provided, `scope` defaults to an empty list for users that have not authorized any scopes for the application.
	// For users who have authorized scopes for the application, the user won't be shown the OAuth authorization page with the list of scopes. Instead, this step of the flow will automatically complete with the set of scopes the user has authorized for the application. For example, if a user has already performed the web flow twice and has authorized one token with `user` scope and another token with `repo` scope, a third web flow that does not provide a `scope` will receive a token with `user` and `repo` scope.
	scope string
	// An unguessable random string. It is used to protect against cross-site request forgery attacks.
	state string
	// Whether or not unauthenticated users will be offered an option to sign up for GitHub during the OAuth flow. The default is `true`. Use `false` when a policy prohibits signups.
	allow_signup bool = true
}

// Get link for web authorization
pub fn (i OAuthLink) web_flow() string {
	mut values := urllib.new_values()
	values.add('client_id', i.client_id)
	values.add('allow_signup', i.allow_signup.str())

	if i.redirect_uri.len > 0 {
		values.add('redirect_uri', i.redirect_uri)
	}

	if i.login.len > 0 {
		values.add('login', i.login)
	}

	if i.scope.len > 0 {
		values.add('scope', i.scope)
	}

	if i.state.len > 0 {
		values.add('state', i.state)
	}

	return 'https://github.com/login/oauth/authorize?' + values.encode()
}

// Get link for device authorization
pub fn (i OAuthLink) device_flow() string {
	mut values := urllib.new_values()
	values.add('client_id', i.client_id)

	if i.scope.len > 0 {
		values.add('scope', i.scope)
	}

	return 'https://github.com/login/device/code?' + values.encode()
}

pub struct OAuthToken {
pub:
	token_type   string
	scope        string
	access_token string
}

pub fn (mut i OAuthToken) from_json(obj json2.Any) {
	json_obj := obj.as_map()
	ju.to(mut i, json_obj)
}

// Requests access token
pub fn exchange_code(client_id string, secret string, code string) ?OAuthToken {
	mut res := http.fetch(
		method: .post
		header: http.new_header(http.HeaderConfig{
			key: .accept
			value: 'application/json'
		})
		url: 'https://github.com/login/oauth/access_token'
		params: {
			'client_id':     client_id
			'client_secret': secret
			'code':          code
		}
	)?
	if res.status() != .ok {
		return error('request returned with bad status: ${res.status()}')
	}

	token := json2.decode[OAuthToken](res.body)?

	if token.access_token.len == 0 {
		return error('token is empty, ${res.body}')
	}

	return token
}
