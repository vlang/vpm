module main

import crypto.hmac
import crypto.rand as crypto_rand
import encoding.base64
import rand
import net.http
import net.urllib
import json2
import veb
import entity { User }
import repo

struct GitHubUser {
	login string
}

struct GitHubOrg {
	login string
}

struct GitHubAccessTokenResponse {
	access_token      string
	error             string
	error_description string
}

const random = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890'
const oauth_state_cookie = 'oauth_state'
const oauth_state_bytes = 32
const oauth_state_max_age = 600

fn random_string(len int) string {
	mut buf := []u8{len: len, init: `0`}
	for i := 0; i < len; i++ {
		idx := rand.intn(random.len) or { 0 }
		buf[i] = random[idx]
	}
	return buf.str()
}

fn new_oauth_state() !string {
	return base64.url_encode(crypto_rand.bytes(oauth_state_bytes)!)
}

const orgs_per_page = 100

fn fetch_all_user_org_names(token string) ![]string {
	mut names := []string{}
	mut page := 1
	for {
		resp := http.fetch(
			url:    'https://api.github.com/user/orgs?per_page=${orgs_per_page}&page=${page}'
			method: .get
			header: http.new_header(key: .authorization, value: 'token ${token}')
		)!

		if resp.status_code != 200 {
			return error('GitHub returned status ${resp.status_code} while fetching organizations')
		}

		gh_orgs := json2.decode[[]GitHubOrg](resp.body)!
		for org in gh_orgs {
			names << org.login
		}

		if gh_orgs.len < orgs_per_page {
			break
		}
		page++
	}
	return names
}

fn extract_github_access_token(body string) !string {
	trimmed_body := body.trim_space()
	if trimmed_body == '' {
		return error('GitHub OAuth response was empty')
	}
	if trimmed_body.starts_with('{') {
		token_resp := json2.decode[GitHubAccessTokenResponse](trimmed_body)!
		if token_resp.access_token != '' {
			return token_resp.access_token
		}
		if token_resp.error_description != '' {
			return error(token_resp.error_description)
		}
		if token_resp.error != '' {
			return error(token_resp.error)
		}
		return error('GitHub OAuth response did not include access_token')
	}

	values := urllib.parse_query(trimmed_body)!
	if token := values.get('access_token') {
		if token != '' {
			return token
		}
	}
	if err_description := values.get('error_description') {
		if err_description != '' {
			return error(err_description)
		}
	}
	if err_name := values.get('error') {
		if err_name != '' {
			return error(err_name)
		}
	}
	return error('GitHub OAuth response did not include access_token')
}

fn extract_github_oauth_query_param(raw_url string, key string) !string {
	mut query := raw_url
	if question_mark_idx := raw_url.index('?') {
		query = raw_url[question_mark_idx + 1..]
	}
	values := urllib.parse_query(query)!
	value := values.get(key) or { return error('GitHub OAuth callback did not include ${key}') }
	if value == '' {
		return error('GitHub OAuth callback ${key} was empty')
	}
	return value
}

fn extract_github_oauth_code(raw_url string) !string {
	return extract_github_oauth_query_param(raw_url, 'code')
}

fn extract_github_oauth_state(raw_url string) !string {
	return extract_github_oauth_query_param(raw_url, 'state')
}

fn validate_github_oauth_state(callback_state string, cookie_state string) ! {
	if callback_state == '' || cookie_state == '' {
		return error('GitHub OAuth state was empty')
	}
	if !hmac.equal(callback_state.bytes(), cookie_state.bytes()) {
		return error('GitHub OAuth state mismatch')
	}
}

fn (mut ctx Context) clear_oauth_state_cookie() {
	ctx.set_cookie(http.Cookie{
		name:    oauth_state_cookie
		value:   ''
		path:    '/oauth_cb'
		max_age: -1
	})
}

@['/login']
fn (app &App) login(mut ctx Context) veb.Result {
	state := new_oauth_state() or {
		println('failed to create GitHub OAuth state')
		return ctx.redirect('/')
	}
	ctx.set_cookie(http.Cookie{
		name:      oauth_state_cookie
		value:     state
		path:      '/oauth_cb'
		max_age:   oauth_state_max_age
		http_only: true
		secure:    app.config.root_url.starts_with('https://')
		same_site: .same_site_lax_mode
	})
	return ctx.redirect(app.github_authorize_link(state))
}

fn (app &App) oauth_cb(mut ctx Context) veb.Result {
	code := extract_github_oauth_code(ctx.req.url) or {
		println('failed to get GitHub OAuth code: ${err}')
		ctx.clear_oauth_state_cookie()
		return ctx.redirect('/')
	}
	state := extract_github_oauth_state(ctx.req.url) or {
		println('failed to get GitHub OAuth state: ${err}')
		ctx.clear_oauth_state_cookie()
		return ctx.redirect('/')
	}
	cookie_state := ctx.get_cookie(oauth_state_cookie) or {
		println('missing GitHub OAuth state cookie')
		ctx.clear_oauth_state_cookie()
		return ctx.redirect('/')
	}
	validate_github_oauth_state(state, cookie_state) or {
		println('invalid GitHub OAuth state')
		ctx.clear_oauth_state_cookie()
		return ctx.redirect('/')
	}
	ctx.clear_oauth_state_cookie()

	resp := http.post_form('https://github.com/login/oauth/access_token', {
		'client_id':     app.config.gh.client_id
		'client_secret': app.config.gh.secret
		'code':          code
	}) or { return ctx.redirect('/') }
	token := extract_github_access_token(resp.body) or {
		println('failed to get GitHub access token: ${err}')
		return ctx.redirect('/')
	}
	// TODO: Handle GitHub user fetch failures without panicking the request.
	user_js := http.fetch(
		url:    'https://api.github.com/user'
		method: .get
		header: http.new_header(key: .authorization, value: 'token ${token}')
	) or { panic(err) }

	if user_js.status_code != 200 {
		println('GitHub returned status ${user_js.status_code} while fetching user')
		return ctx.redirect('/')
	}
	gh_user := json2.decode[GitHubUser](user_js.body) or {
		println('cant decode')
		return ctx.redirect('/')
	}
	login := gh_user.login.replace(' ', '')
	if login.len < 2 {
		return ctx.redirect('/new')
	}
	println('login =${login}')
	mut random_id := random_string(20)
	user := User{
		username:  login
		random_id: random_id
	}
	sql app.db {
		insert user into User
	} or {
		// can already exist, do nothing
	}
	// Fetch the newly created or existing user through UsersRepo and set the
	// authentication cookies. Using the repository keeps this lookup consistent with the ORM's
	// lowercase `user` table name and avoids relying on a raw, incorrectly quoted `"User"` query.
	existing_user := app.users().get_by_name(login) or {
		panic('user was just inserted but could not be found by username: ${login}')
	}
	user_id := existing_user.id
	random_id = existing_user.random_id
	// Store the GitHub token for repository level permission checks during package creation and updates.
	repo.users(app.db).update_github_token(user_id, token) or {
		println('failed to save github token, aborting login: ${err}')
		return ctx.redirect('/')
	}
	// Refresh cached organization memberships without clearing them on a transient GitHub failure.
	// Package operations still require a live repository permission check.
	mut orgs_repo := repo.organizations(app.db)
	if org_names := fetch_all_user_org_names(token) {
		orgs_repo.save_user_organizations(user_id, org_names) or {
			println('failed to save orgs, aborting login: ${err}')
			return ctx.redirect('/')
		}
	} else {
		println('failed to fetch orgs, keeping existing memberships this login: ${err}')
	}

	ctx.set_cookie(
		name:  'id'
		value: user_id.str()
	)
	ctx.set_cookie(
		name:  'q'
		value: random_id
	)
	println('redirecting to /new')
	return ctx.redirect('/new')
}

fn (app &App) auth_user(mut ctx Context) {
	id_cookie := ctx.get_cookie('id') or { return }
	id := id_cookie.int()
	q_cookie := ctx.get_cookie('q') or { return }
	random_id := q_cookie.trim_space()

	ctx.cur_user = User{}
	if id != 0 {
		// App has the DB connection
		cur_user := app.users().get(id, random_id) or { return }
		ctx.cur_user = cur_user
	}
}

pub fn (app &App) auth_middleware(mut ctx Context) bool {
	app.auth_user(mut ctx)
	return true
}

/*
// @[markused]
fn (mut app App) auth() {
	id_cookie := app.get_cookie('id') or { return }
	id := id_cookie.int()
	q_cookie := app.get_cookie('q') or {
		log.info().msg('failed to get q cookie.')
		return
	}
	random_id := q_cookie.trim_space()

	log.info()
		.add('sid', id_cookie)
		.add('id', id)
		.add('len', random_id.len)
		.add('qq', random_id)
		.msg('auth')

	ctx.cur_user = User{}
	if id != 0 {
		cur_user := app.users().get(id, random_id) or { return }
		ctx.cur_user = cur_user
	}
}
*/

fn (app &App) login_link() string {
	return '/login'
}

fn github_authorize_link(client_id string, state string) string {
	mut values := urllib.new_values()
	values.set('response_type', 'code')
	values.set('client_id', client_id)
	values.set('scope', 'read:org')
	values.set('state', state)
	return 'https://github.com/login/oauth/authorize?${values.encode()}'
}

fn (app &App) github_authorize_link(state string) string {
	return github_authorize_link(app.config.gh.client_id, state)
}

fn github_oauth_app_access_link(client_id string) string {
	return 'https://github.com/settings/connections/applications/${client_id}'
}

fn (app &App) github_oauth_app_access_link() string {
	return github_oauth_app_access_link(app.config.gh.client_id)
}
