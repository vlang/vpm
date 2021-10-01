module models

// Backward compatibility for V <=0.2.4
pub struct OldPackage {
pub:
	id           int
	name         string
	vcs          string = 'git'
	url          string
	nr_downloads int
}
