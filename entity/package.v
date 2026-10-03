module entity

import time

@[json: 'package']
pub struct Package {
pub mut:
	id            int    @[primary; sql: serial]
	name          string @[unique]
	description   string
	documentation string
	url           string
	nr_downloads  int
	vcs           string = 'git'
	user_id       int
	author_id     int  @[json: '-']
	author        User @[sql: '-']
	stars         int
	is_flatten    bool // No need to mention author of package, example `ui`
	updated_at    time.Time = time.now()
	created_at    time.Time = time.now()
}

pub fn (p Package) format_name() string {
	return p.name
}

pub fn (p Package) belongs_to_user(user_id int) bool {
	return p.user_id == user_id
}

// score blends the four signals we have into a single ranking number:
//   - nr_downloads + stars * 50   (raw engagement, stars weighted because they
//                                  are a deliberate human signal vs. passive
//                                  download counts)
//   - divided by days_since_created (so a 100k-download package added 2y ago
//                                    doesn't outrank a 30k-download one added
//                                    6mo ago at the same activity level)
//   - multiplied by a 1-year half-decay on `updated_at` (abandonware drifts
//                                                       down without vanishing)
pub fn (p Package) score(now time.Time) i64 {
	now_unix := now.unix()

	secs_since_cre := now_unix - p.created_at.unix()
	days_cre := if secs_since_cre > 86400 { secs_since_cre / 86400 } else { i64(1) }

	secs_since_upd := now_unix - p.updated_at.unix()
	days_upd := if secs_since_upd > 0 { secs_since_upd / 86400 } else { i64(0) }

	rate := (i64(p.nr_downloads) + i64(p.stars) * 50) / days_cre
	// Scale by 1000 before the final divide so packages with similar rates
	// still order deterministically under integer arithmetic.
	return rate * 1000 * 365 / (365 + days_upd)
}
