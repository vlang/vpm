module package

pub enum OrderBy {
	most_downloaded
	recently_updated
	recently_published
}

pub fn (o OrderBy) str() string {
	return match o {
		.most_downloaded { 'downloaded_at' }
		.recently_updated { 'updated_at' }
		.recently_published { 'created_at' }
	}
}
