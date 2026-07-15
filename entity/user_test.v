module entity

import json

// Ensure credential fields are excluded when User values are serialized aspart of public package API responses.
fn test_user_json_excludes_credentials() {
	user := User{
		id:           1
		username:     'someone'
		random_id:    'super-secret-session-token'
		github_token: 'super-secret-oauth-token'
	}
	encoded := json.encode(user)
	assert !encoded.contains('super-secret-session-token')
	assert !encoded.contains('super-secret-oauth-token')
	// Non credential fields should still serialize normally.
	assert encoded.contains('someone')
}
