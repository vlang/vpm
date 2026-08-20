module main

import rand
import net.http
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

const random = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890'

fn random_string(len int) string {
	mut buf := [`0`].repeat(len)
	for i := 0; i < len; i++ {
		idx := rand.intn(random.len) or { 0 }
		buf[i] = random[idx]
	}
	return buf.str()
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

fn (app &App) oauth_cb(mut ctx Context) veb.Result {
	code := ctx.req.url.all_after('code=')
	println(code)
	if code == '' {
		return ctx.redirect('/')
	}

	resp := http.post_form('https://github.com/login/oauth/access_token', {
		'client_id':     app.config.gh.client_id
		'client_secret': app.config.gh.secret
		'code':          code
	}) or { return ctx.redirect('/') }
	println('resp text=' + resp.body)
	token := resp.body.find_between('access_token=', '&')
	println('token =${token}')
	user_js := http.fetch(
		url:    'https://api.github.com/user'
		method: .get
		header: http.new_header(key: .authorization, value: 'token ${token}')
	) or { panic(err) }
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
	return 'https://github.com/login/oauth/authorize?response_type=code&client_id=${app.config.gh.client_id}&scope=read:org'
}
