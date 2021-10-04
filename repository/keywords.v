module repository

import pg
import models

pub struct Keywords {
	db pg.DB
}

pub fn new_keywords(db pg.DB) Keywords {
	return Keywords{
		db: db
	}
}

pub fn (r Keywords) create(slug string, name string) ?models.Keyword {
	row := r.db.exec_one("INSERT INTO $keywords_table (slug, name) VALUES ('$slug', '$name') RETURNING $keywords_fields;") ?
	return models.row2keyword(row)
}

pub fn (r Keywords) get_by_id(id int) ?models.Keyword {
	row := r.db.exec_one('SELECT $keywords_fields FROM $keywords_table WHERE id = $id;') ?
	return models.row2keyword(row)
}

pub fn (r Keywords) get_by_slug(slug string) ?models.Keyword {
	row := r.db.exec_one("SELECT $keywords_fields FROM $keywords_table WHERE slug = '$slug';") ?
	return models.row2keyword(row)
}

pub fn (r Keywords) get_packages(id int) ?[]int {
	query := 'SELECT ${package_keywords_table}.package_id FROM $package_keywords_table ' +
		'INNER JOIN $keywords_table ON ${package_keywords_table}.keyword_id = ${keywords_table}.id' +
		'WHERE ${keywords_table}.id = $id ORDER BY ${keywords_table}.packages DESC;'
	rows := r.db.exec(query) ?

	return rows.map(fn (row pg.Row) int {
		return row.vals[0].int()
	})
}

pub fn (r Keywords) all() ?[]models.Keyword {
	rows := r.db.exec('SELECT $keywords_fields FROM $keywords_table;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Keyword{cap: rows.len}
	for row in rows {
		ctgs << models.row2keyword(&row) ?
	}
	return ctgs
}

pub fn (r Keywords) delete(id int) ?models.Keyword {
	row := r.db.exec_one("DELETE FROM $keywords_table WHERE id = '$id' RETURNING $keywords_fields;") ?
	return models.row2keyword(row)
}
