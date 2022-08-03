module app

import vweb
import vpm.entity
import vpm.lib.log

['/:username'; get]
fn (mut ctx Ctx) user(username string) vweb.Result {
	// user := ctx.user.get_by_username(username) or {
	// 	ctx.message = 'User `$username` does not exist'
	// 	content := $tmpl('./templates/pages/not_found.html')
	// 	layout := $tmpl('./templates/layout.html')
	// 	return send_html(mut ctx, .not_found, layout)
	// }

	if username != "Terisback" {
		ctx.message = 'User `$username` does not exist'
		content := $tmpl('./templates/pages/not_found.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .not_found, layout)
	}

	user := entity.FullUser{
		username: "Terisback"
		name: "Anton Zavodchikov"
		avatar_url: "https://teris.dev/Anton_Zavodchikov.jpg"
	}

	current_user := if isnil(ctx.claims) {
		false
	} else {
		user.username == ctx.claims.user.username
	}

	content := $tmpl('./templates/pages/user.html')
	layout := $tmpl('./templates/layout.html')
	return ctx.html(layout)
}

['/api/users/:username'; get]
fn (mut ctx Ctx) api_user(username string) vweb.Result {
	user := ctx.user.get_by_username(username) or {
		log.error()
			.add('username', username)
			.add('error', err.str())
			.msg('tried to get user')

		return send_json(mut ctx, .not_found, json_error("not found"))
	}

	return ctx.json(user)
}
