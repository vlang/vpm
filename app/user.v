module app

import arrays
import vweb
import entity
import lib.log

['/:username'; get]
fn (mut ctx Ctx) user(username string) vweb.Result {
	user := ctx.user.get_by_username(username) or {
		ctx.message = 'User `$username` does not exist'
		content := $tmpl('./templates/pages/not_found.html')
		layout := $tmpl('./templates/layout.html')
		return send_html(mut ctx, .not_found, layout)
	}

	packages := ctx.package.get_by_author(user.id) or {
		log.error()
			.add('error', err.str())
			.msg('tried to get packages by author')

		[]entity.FullPackage{}
	}

	total_downloads := arrays.fold(packages, 0,
		fn (downloads int, pkg entity.FullPackage) int {
			return downloads + pkg.downloads
		}
	)

	// Helper
	is_current_user := if isnil(ctx.claims) {
		false
	} else {
		user.id == ctx.claims.user.id
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

		return send_json(mut ctx, .not_found, json_error('not found'))
	}

	return ctx.json(user)
}
