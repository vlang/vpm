module local

import os
import crypto.rand
import lib.storage

@[noinit]
pub struct Provider {
pub:
	dir_path string
}

// new local storage provider
pub fn new(path string) !Provider {
	dir_path := os.abs_path(path)
	os.mkdir_all(dir_path)!
	os.ensure_folder_is_writable(dir_path)!
	return Provider{
		dir_path: dir_path
	}
}

// read returns the stored content and its modification time in Unix seconds.
pub fn (p Provider) read(path string) !storage.Entry {
	target_path := p.target_path(path)

	// Just ensuring that we don't go out of provided directory
	p.ensure_still_provider_folder(target_path)!

	file_stat := os.stat(target_path) or {
		if !os.exists(target_path) {
			return storage.err_not_found
		}
		return err
	}
	return storage.Entry{
		data:        os.read_bytes(target_path)!
		modified_at: file_stat.mtime
	}
}

// save writes the content to a temporary file before replacing the stored file.
pub fn (p Provider) save(path string, content []u8) ! {
	target_path := p.target_path(path)

	// Just ensuring that we don't go out of provided directory
	p.ensure_still_provider_folder(target_path)!

	os.mkdir_all(os.dir(target_path))!

	suffix := rand.bytes(16)!
	temp_path := target_path + '.' + suffix.hex() + '.tmp'
	defer {
		os.rm(temp_path) or {}
	}
	os.write_file_array(temp_path, content)!
	$if windows {
		os.mv(temp_path, target_path, overwrite: true)!
	} $else {
		os.rename(temp_path, target_path)!
	}
}

fn (p Provider) target_path(path string) string {
	constructed := p.dir_path + os.path_separator + path.trim_left(os.path_separator)
	return os.norm_path(constructed)
}

fn (p Provider) ensure_still_provider_folder(target string) ! {
	if !target.starts_with(p.dir_path) {
		return error('target path escaped provider directory, target=`${target}`, local_storage=`${p.dir_path}`')
	}
}
