module storage

pub struct Entry {
pub:
	data        []u8
	modified_at i64
}

pub interface Provider {
	read(path string) !Entry
	save(path string, content []u8) !
}
