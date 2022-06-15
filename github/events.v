module github

import time
import net.http
import x.json2
import utils

pub fn parse_event(req http.Request) ?WebhookEvent {
	event := req.header.get_custom('X-GitHub-Event', exact: false)?

	match event {
		'create' {
			return json2.decode<CreateEvent>(req.data) or { return err }
		}
		'delete' {
			return json2.decode<DeleteEvent>(req.data) or { return err }
		}
		'public' {
			return json2.decode<PublicEvent>(req.data) or { return err }
		}
		'star' {
			return json2.decode<StarEvent>(req.data) or { return err }
		}
		else {
			return error('webhook event `$event` not implemented')
		}
	}
}

pub type WebhookEvent = CreateEvent | DeleteEvent | PublicEvent | StarEvent

pub struct CreateEvent {
pub mut:
	ref           string
	ref_type      string
	master_branch string
	description   string
	// Can be `branch` or `tag`
	pusher_type  string
	repository   Repository
	organization User
	installation Installation
	sender       User
}

pub fn (mut e CreateEvent) from_json(obj json2.Any) {
	json_obj := obj.as_map()
	utils.from_json(mut e, json_obj)

	if field := json_obj['repository'] {
		e.repository.from_json(field)
	}

	if field := json_obj['organization'] {
		e.organization.from_json(field)
	}

	if field := json_obj['installation'] {
		e.installation.from_json(field)
	}

	if field := json_obj['sender'] {
		e.sender.from_json(field)
	}
}

pub struct DeleteEvent {
pub mut:
	ref      string
	ref_type string
	// Can be `branch` or `tag`
	pusher_type  string
	repository   Repository
	organization User
	installation Installation
	sender       User
}

pub fn (mut e DeleteEvent) from_json(obj json2.Any) {
	json_obj := obj.as_map()
	utils.from_json(mut e, json_obj)

	if field := json_obj['repository'] {
		e.repository.from_json(field)
	}

	if field := json_obj['organization'] {
		e.organization.from_json(field)
	}

	if field := json_obj['installation'] {
		e.installation.from_json(field)
	}

	if field := json_obj['sender'] {
		e.sender.from_json(field)
	}
}

pub struct PublicEvent {
pub mut:
	repository   Repository
	organization User
	installation Installation
	sender       User
}

pub fn (mut e PublicEvent) from_json(obj json2.Any) {
	json_obj := obj.as_map()

	if field := json_obj['repository'] {
		e.repository.from_json(field)
	}

	if field := json_obj['organization'] {
		e.organization.from_json(field)
	}

	if field := json_obj['installation'] {
		e.installation.from_json(field)
	}

	if field := json_obj['sender'] {
		e.sender.from_json(field)
	}
}

pub struct StarEvent {
pub mut:
	// Can be `created` or `deleted`.
	action string
	// Will be null for the `deleted` action.
	starred_at   time.Time  [omitempty]
	repository   Repository
	organization User
	sender       User
}

pub fn (mut e StarEvent) from_json(obj json2.Any) {
	json_obj := obj.as_map()
	utils.from_json(mut e, json_obj)

	if field := json_obj['repository'] {
		e.repository.from_json(field)
	}

	if field := json_obj['organization'] {
		e.organization.from_json(field)
	}

	if field := json_obj['sender'] {
		e.sender.from_json(field)
	}
}
