module app

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
fn (ctx Ctx) authorize() &JWTClaims {
	token := ctx.get_cookie('Authorization') or { ctx.get_header('Authorization') }

	if token.len == 0 {
		return unsafe { nil }
	}

	claims := jwt.verify<JWTClaims>(token, jwt.new_algorithm(.hs256), ctx.config.jwt.secret) or {
		log.info()
			.add('error', err.str())
			.msg('token is invalid')
		return unsafe { nil }
	}

	return &claims
}

['/login'; get]
fn (mut ctx Ctx) login() vweb.Result {
	if !isnil(ctx.claims) {
		return ctx.redirect(ctx.config.root_url)
	}

	link := github.OAuthLink{
		client_id: ctx.config.gh.client_id
		redirect_uri: ctx.config.root_url + '/auth'
	}

	return ctx.redirect(link.web_flow())
}

pub struct APIAuthenticateResponse {
pub mut:
	token string
}

['/auth'; get]
fn (mut ctx Ctx) authenticate() vweb.Result {
	code := ctx.query['code']

	// TODO: refactor, so not a lot for business logic leaks into controller
	oauth := github.exchange_code(ctx.config.gh.client_id, ctx.config.gh.secret, code) or {
		log.error()
			.add('error', err.str())
			.msg('failed to exchange github code')

		ctx.message = 'Failed to proceed github authentication'
		content := $tmpl('./templates/pages/error.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .bad_request, layout)
	}

	user := ctx.user.authenticate(oauth.access_token) or {
		log.error()
			.add('error', err.str())
			.msg('failed to save user authentication')

		ctx.message = 'Unable to authenticate'
		content := $tmpl('./templates/pages/error.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .internal_server_error, layout)
	}

	claims := JWTClaims{
		user: user
	}

	// Unlimited token exp
	token := jwt.encode(claims, jwt.new_algorithm(.hs256), ctx.config.jwt.secret, 0) or {
		log.error()
			.add('error', err.str())
			.msg('failed to encode jwt')

		ctx.message = 'Unable to authenticate'
		content := $tmpl('./templates/pages/error.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .internal_server_error, layout)
	}

	// If client waits for json, return json
	accepts := ctx.req.header.get(.accept) or { 'application/json' }
	if accepts == 'application/json' {
		return ctx.json(APIAuthenticateResponse{ token: token })
	}

	// Setting Authorization cookie
	ctx.set_cookie(
		name: 'Authorization'
		value: token
		http_only: true
		same_site: .same_site_strict_mode
	)

	return ctx.redirect(ctx.config.root_url)
}

['/logout'; get]
fn (mut ctx Ctx) logout() vweb.Result {
	ctx.set_cookie_with_expire_date('Authorization', '', time.unix(0))
	return ctx.redirect(ctx.config.root_url)
}
