module service

import v.vmod
import io
import os

const (
	registry_path = "/var/lib/vregistry/"
	index_path = registry_path + "index/"
)

pub fn new_registry(url string) ?RegistryService   {
	create_dir_if_not_exists(registry_path)
	create_dir_if_not_exists(index_path)

	return RegistryService {}
}

pub struct RegistryService {}

// Add file to index
pub fn (r RegistryService ) add_to_index(file_name string, content io.Reader) ? {
	io.cp(content, os.create(index_path + file_name)?)?
}

// Give file as io.Reader
pub fn (r RegistryService ) take_from_index(file_name string) ?io.Reader {
	return os.open(file_name)?
}

fn create_dir_if_not_exists(path string) ?bool {
	return if !os.exists(path) {
		os.mkdir(path)
	} else {
		none
	}
}