module package

pub struct CreateTagDTO {
pub mut:
	package_id int
	name string
	vcs string = 'git'
	url string
}

pub enum OrderBy {
	most_downloaded
	recently_updated
	recently_published
}

pub fn (o OrderBy) str() string {
	return match o {
		.most_downloaded { "most_downloaded" }
		.recently_updated { "recently_updated" }
		.recently_published { "recently_published" }
	}
}
