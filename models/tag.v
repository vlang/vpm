module models

pub struct Tag {
pub:
	id          int
	name        string
	nr_packages int    [json: packages]
}
