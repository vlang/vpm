module main

import rand
import net.http
import json
import veb
import entity { User }
import lib.log

struct GitHubUser {
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
	gh_user := json.decode(GitHubUser, user_js.body) or {
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
	// Fetch the new or already existing user and set cookies
	user_id := app.db.q_int("select id from \"User\" where username='${login}' ") or { panic(err) }
	random_id = app.db.q_string("select random_id from \"User\" where username='${login}' ") or {
		panic(err)
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
	return 'https://github.com/login/oauth/authorize?response_type=code&client_id=${app.config.gh.client_id}'
}
