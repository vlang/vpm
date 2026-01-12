module entity

import time

@[json: 'user_organization']
pub struct UserOrganization {
pub mut:
	id         int    @[primary; sql: serial]
	user_id    int
	org_name   string
	created_at time.Time = time.now()
}
