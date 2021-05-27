module models

// For backward compatibility for V <=0.2.2
pub struct OldPackage {
pub:
	id           int
	name         string
	vcs          string
	url          string
	nr_downloads int
}
