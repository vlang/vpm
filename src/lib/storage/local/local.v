module local

import os
import lib.storage

[noinit]
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

pub fn (p Provider) read(path string) ![]u8 {
	target_path := p.target_path(path)

	// Just ensuring that we don't go out of provided directory
	p.ensure_still_provider_folder(target_path)!

	// Read file
	data := os.read_file(target_path) or {
		if err.msg().starts_with('failed to open file') {
			return storage.err_not_found
		}

		return err
	}
	return data.bytes()
}

pub fn (p Provider) save(path string, content []u8) ! {
	target_path := p.target_path(path)

	// Just ensuring that we don't go out of provided directory
	p.ensure_still_provider_folder(target_path)!

	os.mkdir_all(os.dir(target_path))!

	// Write file
	os.write_file_array(target_path, content)!
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

// red
// normalize
// check if we out of our dir
// read

// write
// normalize
// check if we out of dir
// write
