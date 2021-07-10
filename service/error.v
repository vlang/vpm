module service

import repository

fn s_err(err IError) string {
	return '[$err.code] $err.msg'
}

pub struct NotFoundError {
pub:
	msg  string = "doesn't exists"
	code int
}

pub fn (err NotFoundError) str() string {
	return s_err(err)
}

fn from_repo_not_found(err repository.NotFoundError) IError {
	return IError(&NotFoundError{
		msg: err.msg
		code: err.code
	})
}

fn not_found(entity string) IError {
	return IError(&NotFoundError{
		msg: '$entity doesn\'t exists'
	})
}

// *alias to ConsraintError from repository module
pub struct AlreadyExists {
pub:
	msg  string = 'already exists'
	code int
}

pub fn (err AlreadyExists) str() string {
	return s_err(err)
}

fn from_repo_already_exists(err repository.ConstraintError) IError {
	return IError(&AlreadyExists{
		msg: err.msg
		code: err.code
	})
}

pub struct IncorrectInputError {
pub:
	msg  string = 'input is fucked up'
	code int
}

pub fn (err IncorrectInputError) str() string {
	return s_err(err)
}

fn incorrect_input(fieldname string) IError {
	return IError(&IncorrectInputError{
		msg: '$fieldname field received incorrect data'
	})
}

fn wrap_err(err IError) IError {
	match err {
		repository.NotFoundError {
			return from_repo_not_found(err)
		}
		repository.ConstraintError {
			return from_repo_already_exists(err)
		}
		else {
			return err
		}
	}
}
