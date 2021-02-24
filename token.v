module main

import sqlite

struct Token {
	id int
	user_id int
	value string
	ip string
}

fn token_from_row(row sqlite.Row) Token {
	return Token{
		id: row.vals[0].int()
		user_id: row.vals[1].int()
		value: row.vals[2]
		ip: row.vals[3]
	}
}

fn (mut app App) update_user_token(user_id int, token string, ip string) string {
	tok := app.find_user_token(user_id, ip) or { '' }
	if tok == '' {
		new_token := Token{user_id: user_id, value: token, ip: ip }
		app.db.insert(new_token)
		return token
	}
	return tok
}

fn (mut app App) find_user_token(user_id int, ip string) ?string {
	row := app.db.exec_one('select from Token where (user_id=${user_id} and ip=${ip})') or {
		return error('sql error: ${err}')
	}
	return token_from_row(row).value
}

fn (mut app App) clear_sessions(user_id int) ? {
	code := app.db.exec_none('delete from Token where user_id=${user_id}')
	if code != 0 {
		return error('sql result code ${code}')
	}
}

fn (mut app App) add_token(user_id int, ip string) string {
	mut token := gen_uuid_v4ish()
	token = app.update_user_token(user_id, token, ip)
	return token
}