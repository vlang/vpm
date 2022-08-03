module log

pub enum Level {
	panic = 0
	fatal
	error
	warn
	info
	debug
}

pub fn (level Level) str() string {
	return match level {
		.panic { "panic" }
		.fatal { "fatal" }
		.error { "error" }
		.warn { "warn" }
		.info { "info" }
		.debug { "debug" }
	}
}

pub fn level_from_str(level string) Level {
	return match level {
		"panic" { .panic }
		"fatal" { .fatal }
		"error" { .error }
		"warn" { .warn }
		"info" { .info }
		"debug" { .debug }
		else { .info }
	}
}
