module storage

pub interface Provider {
	read(path string) ![]u8
	save(path string, content []u8) !
}
