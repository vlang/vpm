module main

/*
import time
import vweb
import entity
import lib.github
import lib.jwt
import lib.log

pub struct JWTClaims {
pub:
	user entity.User
}

// Checks for 'Authorization' header or 'Authorization' cookie and decodes token into JWTClaims
fn (app App) authorize() &JWTClaims {
	token := app.get_cookie('Authorization') or { app.get_header('Authorization') }

	if token.len == 0 {
		return unsafe { nil }
	}

	claims := jwt.verify[JWTClaims](token, jwt.new_algorithm(.hs256), app.config.jwt.secret) or {
		log.info()
			.add('error', err.str())
			.msg('token is invalid')
		return unsafe { nil }
	}

	return &claims
}

['/login'; get]
fn (mut app App) login() vweb.Result {
	if !isnil(app.claims) {
		return app.redirect(app.config.root_url)
	}

	link := github.OAuthLink{
		client_id: app.config.gh.client_id
		redirect_uri: app.config.root_url + '/auth'
	}

	return app.redirect(link.web_flow())
}

pub struct APIAuthenticateResponse {
pub mut:
	token string
}

['/auth'; get]
fn (mut app App) authenticate() vweb.Result {
	code := app.query['code']

	// TODO: refactor, so not a lot for business logic leaks into controller
	oauth := github.exchange_code(app.config.gh.client_id, app.config.gh.secret, code) or {
		log.error()
			.add('error', err.str())
			.msg('failed to exchange github code')
		app.error('Failed to proceed github authentication')
		return app.server_error(501)
	}

	user := app.cur_user.authenticate(oauth.access_token) or {
		log.error()
			.add('error', err.str())
			.msg('failed to save user authentication')

		return vweb.server_error(501)
	}

	claims := JWTClaims{
		user: user
	}

	// Unlimited token exp
	token := jwt.encode(claims, jwt.new_algorithm(.hs256), app.config.jwt.secret, 0) or {
		log.error()
			.add('error', err.str())
			.msg('failed to encode jwt')

		return vweb.server_error(501)
	}

	// If client waits for json, return json
	accepts := app.req.header.get(.accept) or { 'application/json' }
	if accepts == 'application/json' {
		return app.json(APIAuthenticateResponse{ token: token })
	}

	// Setting Authorization cookie
	app.set_cookie(
		name: 'Authorization'
		value: token
		http_only: true
		same_site: .same_site_strict_mode
	)

	return app.redirect(app.config.root_url)
}

['/logout'; get]
fn (mut app Ctx) logout() vweb.Result {
	app.set_cookie_with_expire_date('Authorization', '', time.unix(0))
	return app.redirect(app.config.root_url)
}
*/
