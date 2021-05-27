module models

pub struct Category {
pub:
	id          int
	name        string
	nr_packages int    [json: packages]
}
