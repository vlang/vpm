module repository

fn s_err(err IError) string {
	return '[$err.code()] $err.msg()'
}

[noinit]
pub struct SQLError {
pub:
	msg  string
	code int
}

pub fn (err SQLError) msg() string {
	return err.msg
}

pub fn (err SQLError) code() int {
	return err.code
}

pub fn (err SQLError) str() string {
	return s_err(err)
}

[noinit]
pub struct NotFoundError {
pub:
	msg  string = 'no records found'
	code int    = 1
}

pub fn (err NotFoundError) msg() string {
	return err.msg
}

pub fn (err NotFoundError) code() int {
	return err.code
}

pub fn (err NotFoundError) str() string {
	return s_err(err)
}

fn not_found() IError {
	return IError(&NotFoundError{})
}

[noinit]
pub struct ConstraintError {
pub:
	msg  string = 'probably record already exists'
	code int    = 2
}

pub fn (err ConstraintError) msg() string {
	return err.msg
}

pub fn (err ConstraintError) code() int {
	return err.code
}

pub fn (err ConstraintError) str() string {
	return s_err(err)
}
