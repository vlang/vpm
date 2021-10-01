module repository

import time
import models

interface Row {
	vals []string
}

struct RowIterator {
	vals []string
mut:
	idx usize
}

fn row_iterator(row Row) RowIterator {
	return RowIterator{
		vals: row.vals
	}
}

fn (mut iter RowIterator) next() ?string {
	if iter.idx >= iter.vals.len {
		return error('out of bounds')
	}

	defer {
		iter.idx++
	}

	return iter.vals[iter.idx]
}

fn row2category(row Row) ?models.Category {
	mut i := row_iterator(row)

	return models.Category{
		id: i.next() ?.int()
		slug: i.next() ?
		name: i.next() ?
	}
}

fn row2package(row Row) ?models.Package {
	mut i := row_iterator(row)

	return models.Package{
		id: i.next() ?.int()
		author_id: i.next() ?.int()
		name: i.next() ?
		description: i.next() ?
		license: i.next() ?
		repo_url: i.next() ?
		stars: i.next() ?.int()
		downloads: i.next() ?.int()
		downloaded_at: time.unix(i.next() ?.i64())
		created_at: time.unix(i.next() ?.i64())
		updated_at: time.unix(i.next() ?.i64())
	}
}

fn row2tag(row Row) ?models.Tag {
	mut i := row_iterator(row)

	return models.Tag{
		id: i.next() ?.int()
		slug: i.next() ?
		name: i.next() ?
	}
}

// fn row2token(row Row) ?Tag {
// 	mut i := row_iterator(row)

// 	return models.Tag{
// 		user_id: i.next()?
// 		access_token: i.next()?
// 	}
// }

fn row2user(row Row) ?models.User {
	mut i := row_iterator(row)

	return models.User{
		id: i.next() ?.int()
		github_id: i.next() ?.int()
		login: i.next() ?
		name: i.next() ?
		avatar_url: i.next() ?
		is_blocked: i.next() ?.bool()
		is_admin: i.next() ?.bool()
	}
}

fn row2version(row Row) ?models.Version {
	mut i := row_iterator(row)

	return models.Version{
		id: i.next() ?.int()
		package_id: i.next() ?.int()
		tag: i.next() ?
		downloads: i.next() ?.int()
		commit_hash: i.next() ?
		release_url: i.next() ?
		release_date: time.unix(i.next() ?.i64())
	}
}
