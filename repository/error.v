module repository

pub struct SQLError {
	msg string
	code int
}

pub fn (err SQLError) str() string {
	return '[ERROR_CODE:$err.code] $err.msg'
}

pub struct NotFoundError {
	msg string = "No records found"
	code int
}

pub fn (err NotFoundError) str() string {
	return '[CODE:$err.code] $err.msg'
}