module config

pub struct Config {
	sqlite SqliteConfig
	http HTTPConfig
}

pub struct SqliteConfig {
	path string
}

pub struct HTTPConfig {
	host string
	port string
	read_timeout int
	write_timeout int
	max_header_megabytes int
}
