module html

import maps
import net.html as net_html
import net.urllib
import strings

const allowed_tags = [
	'h1',
	'h2',
	'h3',
	'h4',
	'h5',
	'h6',
	'h7',
	'h8',
	'br',
	'b',
	'i',
	'strong',
	'em',
	'a',
	'pre',
	'code',
	'img',
	'tt',
	'div',
	'ins',
	'del',
	'sup',
	'sub',
	'p',
	'ol',
	'ul',
	'text',
	'table',
	'thead',
	'tbody',
	'tfoot',
	'blockquote',
	'dl',
	'dt',
	'dd',
	'kbd',
	'q',
	'samp',
	'var',
	'hr',
	'ruby',
	'rt',
	'rp',
	'li',
	'tr',
	'td',
	'th',
	's',
	'strike',
	'summary',
	'details',
]!

const allowed_attributes = [
	'abbr',
	'accept',
	'accept-charset',
	'accesskey',
	'action',
	'align',
	'alt',
	'axis',
	'border',
	'class',
	'cellpadding',
	'cellspacing',
	'char',
	'charoff',
	'charset',
	'checked',
	'clear',
	'cols',
	'colspan',
	'color',
	'compact',
	'coords',
	'datetime',
	'dir',
	'disabled',
	'enctype',
	'for',
	'frame',
	'headers',
	'height',
	'hreflang',
	'hspace',
	'ismap',
	'label',
	'lang',
	'maxlength',
	'media',
	'method',
	'multiple',
	'name',
	'nohref',
	'noshade',
	'nowrap',
	'open',
	'prompt',
	'readonly',
	'rel',
	'rev',
	'rows',
	'rowspan',
	'rules',
	'scope',
	'selected',
	'shape',
	'size',
	'span',
	'start',
	'summary',
	'tabindex',
	'target',
	'title',
	'type',
	'usemap',
	'valign',
	'value',
	'vspace',
	'width',
	'itemprop',
]!

pub fn sanitize(text string) string {
	// !!! '<c>' is workaround, parse returns first tag as dom root,
	// !!! so first tag in readme wraps whole content
	dom := net_html.parse('<c>' + text + '</c>')

	mut root := dom.get_root()
	if root == unsafe { nil } {
		return ''
	}

	for t in root.children {
		traverse_and_sanitize(&t)
	}

	unsafe {
		root.children = root.children.filter(it != nil)
	}
	return to_string(root)#[3..-4]
}

fn traverse_and_sanitize(tag &&net_html.Tag) {
	if tag.name == 'br' {
		unsafe {
			tag.close_type = .in_name
		}
	}

	// Filter allowed tags
	if tag.name !in allowed_tags {
		match true {
			tag.name == 'input' && tag.attributes['type'] == 'checkbox' {}
			else {
				println('met ${tag.name} EXTERMINATE')
				unsafe {
					*tag = nil
				}
				return
			}
		}
	}

	// Filter allowed attributes
	unsafe {
		match true {
			// Filter protocols for a with href
			tag.name == 'a' {
				mut attributes := map[string]string{}
				for k, v in tag.attributes {
					if k == 'href' {
						url := urllib.parse(v) or { urllib.URL{} }
						if url.scheme in ['http', 'https', 'mailto', 'github-windows', 'github-mac',
							'x-github-client'] {
							attributes['href'] = v
						}
					} else if k in allowed_attributes {
						attributes[k] = v
					}
				}
				tag.attributes = attributes.move()
			}
			// Filter protocols for specific tags
			tag.name in ['blockquote', 'del', 'ins', 'q'] {
				mut attributes := map[string]string{}
				for k, v in tag.attributes {
					if k == 'cite' {
						url := urllib.parse(v) or { urllib.URL{} }
						if url.scheme in ['http', 'https'] {
							attributes['cite'] = v
						}
					} else if k in allowed_attributes {
						attributes[k] = v
					}
				}
				tag.attributes = attributes.move()
			}
			// Filter protocols for img with src
			tag.name == 'img' {
				mut attributes := map[string]string{}
				for k, v in tag.attributes {
					if k in ['src', 'longdesc'] {
						url := urllib.parse(v) or { urllib.URL{} }
						if url.scheme in ['http', 'https'] {
							attributes[k] = v
						}
					} else if k in allowed_attributes {
						attributes[k] = v
					}
				}
				tag.attributes = attributes.move()
			}
			tag.name in ['pre', 'code'] {
				mut attributes := map[string]string{}
				for k, v in tag.attributes {
					if k == 'class' {
						if tag.class_set.exists('language-vlang') {
							attributes['class'] = 'language-v ' + v
						} else {
							attributes['class'] = v
						}
					} else if k in allowed_attributes {
						attributes[k] = v
					}
				}
				tag.attributes = attributes.move()
			}
			else {
				tag.attributes = maps.filter(tag.attributes, fn (k string, v string) bool {
					return k in allowed_attributes
				})
			}
		}
	}
	for i := 0; i < tag.children.len; i++ {
		traverse_and_sanitize(&tag.children[i])
	}

	unsafe {
		tag.children = tag.children.filter(it != nil)
	}
}

fn to_string(tag &net_html.Tag) string {
	mut html_str := strings.new_builder(64)
	html_str.write_string('<${tag.name}')
	for key, value in tag.attributes {
		html_str.write_string(' ${key}')
		if value.len > 0 {
			html_str.write_string('="${value}"')
		}
	}
	html_str.write_string(if tag.closed && tag.close_type == .in_name { '/>' } else { '>' })
	html_str.write_string(tag.content)
	if tag.children.len > 0 {
		for child in tag.children {
			html_str.write_string('\n' + to_string(child))
		}
	}
	if !tag.closed || tag.close_type == .new_tag {
		html_str.write_string('</${tag.name}>')
	}
	return html_str.str()
}
