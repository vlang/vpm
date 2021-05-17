module auth

import os
import rand
import math
import crypto.sha256

const (
	client_id     = os.getenv('VPM_GITHUB_CLIENT_ID')
)

fn init() {
	if client_id == "" {
		eprintln('Please set client id via env variable `VPM_GITHUB_CLIENT_ID`')
		panic('No github client id is specified')
	}
}

fn (mut app App) get_login_link() string {
	return 'https://github.com/login/oauth/authorize?response_type=code&client_id=$client_id'
}

fn make_password(password string, username string) string {
	mut seed := [u32(username[0]), u32(username[1])]
	rand.seed(seed)
	salt := rand.i64().str()
	pw := '$password$salt'
	return sha256.sum(pw.bytes()).hex().str()
}

fn (mut app App) client_ip(username string) ?string {
	return make_password(app.ip(), '${username}token')
}

fn (mut app App) logged_in() bool {
	id := app.get_cookie('id') or { return false }
	token := app.get_cookie('token') or { return false }
	ip := app.client_ip(id) or { return false }
	t := app.find_user_token(id.int(), ip) or { '' }
	user := app.get_user(id.int()) or { User{} }
	blocked := user.is_blocked
	if blocked {
		app.logout()
		return false
	}
	return id != '' && token != '' && t != '' && t == token
}

fn (mut app App) get_user_from_cookies() ?User {
	id := app.get_cookie('id') or { return none }
	token := app.get_cookie('token') or { return none }
	mut user := app.get_user(id.int()) or { return none }
	ip := app.client_ip(id) or { return none }
	user_token := app.find_user_token(user.id, ip) or { '' }
	if token != user_token {
		return none
	}
	user.b_avatar = user.avatar != ''
	if !user.b_avatar {
		user.avatar = user.username.bytes()[0].str()
	}
	return user
}

fn gen_uuid_v4ish() string {
	// UUIDv4 format: 4-2-2-2-6 bytes per section
	a := rand.intn(math.max_i32 / 2).hex()
	b := rand.intn(math.max_i16).hex()
	c := rand.intn(math.max_i16).hex()
	d := rand.intn(math.max_i16).hex()
	e := rand.intn(math.max_i32 / 2).hex()
	f := rand.intn(math.max_i16).hex()
	return '${a:08}-${b:04}-${c:04}-${d:04}-${e:08}${f:04}'.replace(' ', '0')
}
