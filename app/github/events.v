module github

import time
import net.http
import json

pub fn parse_event(req http.Request) ?WebhookEvent {
	event := req.header.get_custom('X-GitHub-Event', exact: false) ?

	match event {
		'create' {
			return json.decode(CreateEvent, req.data) or { return err }
		}
		'delete' {
			return json.decode(DeleteEvent, req.data) or { return err }
		}
		'public' {
			return json.decode(PublicEvent, req.data) or { return err }
		}
		'star' {
			return json.decode(StarEvent, req.data) or { return err }
		}
		else {
			return error('webhook event `$event` not implemented')
		}
	}
}

pub type WebhookEvent = CreateEvent | DeleteEvent | PublicEvent | StarEvent

pub struct CreateEvent {
pub:
	ref           string
	ref_type      string
	master_branch string
	description   string
	// Can be `branch` or `tag`
	pusher_type  string
	repository   &Repository
	organization &User
	installation &Installation
	sender       &User
}

struct DeleteEvent {
pub:
	ref      string
	ref_type string
	// Can be `branch` or `tag`
	pusher_type  string
	repository   &Repository
	organization &User
	installation &Installation
	sender       &User
}

struct PublicEvent {
	repository   &Repository
	organization &User
	installation &Installation
	sender       &User
}

struct StarEvent {
	// Can be `created` or `deleted`.
	action string
	// Will be null for the `deleted` action.
	starred_at   time.Time   [omitempty]
	repository   &Repository
	organization &User
	sender       &User
}
