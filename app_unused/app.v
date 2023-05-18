module app

import pg
import vweb
import config
import lib.log
import app_unused.repo
import app_unused.usecase.package
import app_unused.usecase.user

[heap]
struct Ctx {
	vweb.Context
mut:
	// Config
	config config.Config [vweb_global]

	// Use cases
	package package.UseCase [vweb_global]
	user    user.UseCase    [vweb_global]
pub mut:
	// Decoded jwt claims, if there is
	claims &JWTClaims = unsafe { nil }
	// Added in some page templates
	message string
	// Added to end of meta, when html is rendered through `layout.html`
	to_meta string
	// Added to end of body, when html is rendered through `layout.html`
	to_body string
}

pub fn (mut ctx Ctx) before_request() {
	log.info()
		.add('method', ctx.req.method.str())
		.add_map('params', ctx.query)
		.add('url', ctx.req.url.split_nth('?', 2)[0])
		.msg('request')

	ctx.claims = ctx.authorize()
}

pub fn run(cfg config.Config) ? {
	db := pg.connect(pg.Config{
		host: cfg.pg.host
		port: cfg.pg.port
		user: cfg.pg.user
		password: cfg.pg.password
		dbname: cfg.pg.db
	})?

	auth_repo := repo.new_auth_repo(db)
	category_repo := repo.new_category_repo(db)
	package_repo := repo.new_package_repo(db)
	user_repo := repo.new_user_repo(db)

	package_use_case := package.new_use_case(cfg.gh, category_repo, package_repo, user_repo)
	user_use_case := user.new_use_case(cfg.gh, auth_repo, user_repo)

	mut ctx := &Ctx{
		config: cfg
		package: package_use_case
		user: user_use_case
	}
	ctx.handle_static('./app/static', true)
	vweb.run(ctx, cfg.http.port)
}
