module main

import lib.storage.local
import os
import rand
import time

const test_readme_path = 'packages_readme/1/README.html'

fn expire_readme(dir string) ! {
	old := time.now().unix() - readme_cache_lifetime_seconds - 1
	os.utime(os.join_path(dir, test_readme_path), old, old)!
}

fn test_package_readme_refreshes_after_cache_expiry() {
	dir := os.join_path(os.temp_dir(), 'vpm-readme-' + rand.uuid_v4())
	cache := local.new(dir)!
	defer {
		os.rmdir_all(dir) or {}
	}

	original := get_readme(cache, test_readme_path, fn () !string {
		return '# Original README'
	})!
	assert original.contains('<h1>Original README</h1>')

	fresh := get_readme(cache, test_readme_path, fn () !string {
		assert false, 'fresh cache should not fetch'
		return ''
	})!
	assert fresh == original

	expire_readme(dir)!
	stale := get_readme(cache, test_readme_path, fn () !string {
		return error('temporary failure')
	})!
	assert stale == original

	updated := get_readme(cache, test_readme_path, fn () !string {
		return '# Updated README'
	})!
	assert updated.contains('<h1>Updated README</h1>')
	saved := cache.read(test_readme_path)!
	assert saved.data.bytestr() == updated

	expire_readme(dir)!
	assert get_readme(cache, test_readme_path, fn () !string {
		return ''
	})! == ''
	assert get_readme(cache, test_readme_path, fn () !string {
		assert false, 'fresh cache should also remember an absent README'
		return ''
	})! == ''
}
