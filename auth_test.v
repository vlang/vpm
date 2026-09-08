module main

import net.urllib

fn test_extract_github_access_token_from_form_response() {
	token := extract_github_access_token('access_token=abc123&scope=read%3Aorg&token_type=bearer')!
	assert token == 'abc123'
}

fn test_extract_github_access_token_from_form_response_without_trailing_field() {
	token := extract_github_access_token('scope=read%3Aorg&token_type=bearer&access_token=abc123')!
	assert token == 'abc123'
}

fn test_extract_github_access_token_from_json_response() {
	token :=
		extract_github_access_token('{"access_token":"abc123","scope":"read:org","token_type":"bearer"}')!
	assert token == 'abc123'
}

fn test_extract_github_access_token_reports_github_errors() {
	if token := extract_github_access_token('{"error":"bad_verification_code","error_description":"The code passed is incorrect or expired."}') {
		assert false, 'expected an OAuth error, got token ${token}'
	}
}

fn test_extract_github_oauth_code_ignores_issuer_query_param() {
	code :=
		extract_github_oauth_code('/oauth_cb?code=abc123&iss=https%3A%2F%2Fgithub.com%2Flogin%2Foauth')!
	assert code == 'abc123'
}

fn test_extract_github_oauth_state_ignores_extra_query_params() {
	state :=
		extract_github_oauth_state('/oauth_cb?code=abc123&state=s123&iss=https%3A%2F%2Fgithub.com%2Flogin%2Foauth')!
	assert state == 's123'
}

fn test_validate_github_oauth_state_accepts_match() {
	validate_github_oauth_state('same-state', 'same-state') or {
		assert false, 'matching OAuth state should be accepted'
	}
}

fn test_validate_github_oauth_state_rejects_mismatch() {
	validate_github_oauth_state('callback-state', 'cookie-state') or { return }
	assert false, 'mismatched OAuth state must be rejected'
}

fn test_github_authorize_link_includes_state() {
	authorize_url := github_authorize_link('Iv1.testclient', 'state with spaces')
	assert authorize_url.starts_with('https://github.com/login/oauth/authorize?')
	values := urllib.parse_query(authorize_url.all_after('?'))!
	assert values.get('client_id') or { '' } == 'Iv1.testclient'
	assert values.get('scope') or { '' } == 'read:org'
	assert values.get('state') or { '' } == 'state with spaces'
}

fn test_github_oauth_app_access_link_uses_client_id() {
	assert github_oauth_app_access_link('Iv1.testclient') == 'https://github.com/settings/connections/applications/Iv1.testclient'
}
