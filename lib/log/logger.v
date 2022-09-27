// dead simple logger
module log

import os
import time
import x.json2 as j2

pub const logging_level = level_from_str(os.getenv('VPM_LOG'))

[noinit]
pub struct Logger {
	level  Level
	fields []Field
}

pub fn panic() Logger {
	return with_level(.panic)
}

pub fn fatal() Logger {
	return with_level(.fatal)
}

pub fn error() Logger {
	return with_level(.error)
}

pub fn warn() Logger {
	return with_level(.warn)
}

pub fn info() Logger {
	return with_level(.info)
}

pub fn debug() Logger {
	return with_level(.debug)
}

pub fn with_level(level Level) Logger {
	return Logger{
		level: level
	}
}

pub fn (logger Logger) add<T>(key string, value T) Logger {
	return logger.add_json(key, j2.Any(value))
}

pub fn (logger Logger) add_map<T>(key string, value map[string]T) Logger {
	mut some_map := map[string]j2.Any{}
	for k, v in value {
		some_map[k] = j2.Any(v)
	}
	return logger.add_json(key, some_map)
}

pub fn (logger Logger) add_json(key string, value j2.Any) Logger {
	mut fields := logger.fields.clone()
	fields << Field{
		key: key
		value: value
	}
	return Logger{
		...logger
		fields: fields
	}
}

pub fn (logger Logger) msg(message string) {
	if int(log.logging_level) < int(logger.level) {
		return
	}

	mut jmap := map[string]j2.Any{}
	jmap['level'] = j2.Any(logger.level.str())
	jmap['timestamp'] = j2.Any(time.now().format_ss_milli())
	for _, field in logger.fields {
		jmap[field.key] = field.value
	}
	jmap['msg'] = j2.Any(message)
	println(jmap.str())
}
