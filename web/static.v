module web

import os
import net
import net.http
import net.urllib

// TODO: Config for router.static
// pub struct Static {
// pub:
//  compress bool
//  // file browser
// 	browse bool
// }

struct StaticFile {
	mime_type string
	path      string
}

// check if request is for a static file and serves it
// returns true if we served a static file, false otherwise
[manualfree]
fn (router Router<T>) serve_if_static(mut conn net.TcpConn, url urllib.URL) bool {
	static_file := router.static_files[url.path] or { return false }

	// TODO: Open file stream, send chunked
	data := os.read_file(static_file.path) or {
		println('File `$static_file.path` not found for route `$url.path`')
		conn.write(http_404.bytes()) or {}
		return true
	}
	defer {
		unsafe { data.free() }
	}

	conn.write(http.new_response(
		header: http.new_header_from_map({
			http.CommonHeader.server:       router.config.server_header
			http.CommonHeader.content_type: static_file.mime_type
			http.CommonHeader.connection:   'close'
		})
		text: data
	).bytes()) or {
		println("Can't send static - $err")
		return false
	}

	return true
}

fn scan_static_directory(mount_at string, dir string) ?map[string]StaticFile {
	mut static_files := map[string]StaticFile{}

	files := os.ls(dir) ?
	if files.len == 0 {
		return static_files
	}

	for file in files {
		full_path := os.join_path(dir, file)
		new_mount := '/' + (mount_at + '/' + file).split('/').filter(it.len > 0).join('/')
		if os.is_dir(full_path) {
			concat_static_files(mut static_files, scan_static_directory(new_mount, full_path) ?)
		} else if file.contains('.') && !file.starts_with('.') && !file.ends_with('.') {
			ext := os.file_ext(file)
			// Rudimentary guard against adding files not in mime_types.
			// Use serve_static directly to add non-standard mime types.
			if ext in mime_types {
				static_files[new_mount] = StaticFile{
					mime_type: mime_types[ext]
					path: full_path
				}
			}
		}
	}

	return static_files
}

fn concat_static_files(mut left map[string]StaticFile, right ...map[string]StaticFile) {
	for m in right {
		for k, v in m {
			left[k] = v
		}
	}
}
