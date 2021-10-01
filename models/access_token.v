module models

import time

pub struct AccessToken {
pub:
	user_id int
	// uuid_v4
	value string
	// Represents ipv4 address
	ip         u32
	created_at time.Time
}
