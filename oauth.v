module main

import rand
import net.http
import json
import os

const (
	client_id     = os.getenv('VPM_GITHUB_CLIENT_ID')
	client_secret = os.getenv('VPM_GITHUB_SECRET')
)

struct GitHubUser {
	login string
}

const (
	random = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890'
)

fn random_string(len int) string {
	mut buf := [`0`].repeat(len)
	for i := 0; i < len; i++ {
		idx := rand.next(random.len)
		buf[i] = random[idx]
	}
	return string(buf)
}

fn (mut app App) oauth_cb() {
	code := app.vweb.req.url.all_after('code=')
	println(code)
	if code == '' {
		return
	}
	d := 'client_id=$client_id&client_secret=$client_secret&code=$code'
	resp := http.post('https://github.com/login/oauth/access_token', d) or {
		return
	}
	println('resp text=' + resp.text)
	token := resp.text.find_between('access_token=', '&')
	println('token =$token')
	user_js := http.fetch('https://api.github.com/user?access_token=$token', {
		method: 'GET'
		headers: {
			'User-Agent': 'V http client'
		}
	}) or {
		panic(err)
	}
	gh_user := json.decode(GitHubUser, user_js.text) or {
		println('cant decode')
		return
	}
	login := gh_user.login.replace(' ', '')
	if login.len < 2 {
		app.vweb.redirect('/new')
		return
	}
	println('login =$login')
	mut random_id := random_string(20)
	app.db.exec_param2('insert into users (name, random_id) values ($1, $2)', login, random_id)
	// Fetch the new or already existing user and set cookies
	user_id := app.db.q_int("select id from users where name=\'$login\' ")
	random_id = app.db.q_string("select random_id from users where name=\'$login\' ")
	app.vweb.set_cookie('id', user_id.str())
	app.vweb.set_cookie('q', random_id)
	println('redirecting to /new')
	app.vweb.redirect('/new')
}

fn (mut app App) auth() {
	id_cookie := app.vweb.get_cookie('id') or {
		println('failed to id cookie')
		return
	}
	id := id_cookie.int()
	q_cookie := app.vweb.get_cookie('q') or {
		println('failed to get q cookie.')
		return
	}
	random_id := q_cookie.trim_space()
	println('auth sid="$id_cookie" id=$id len ="$random_id.len" qq="$random_id" !!!')
	app.cur_user = User{}
	if id != 0 {
		cur_user := app.retrieve_user(id, random_id) or {
			return
		}
		app.cur_user = cur_user
	}
}
