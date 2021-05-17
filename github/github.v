module github

const (
	client_id     = os.getenv('VPM_GITHUB_CLIENT_ID')
	client_secret = os.getenv('VPM_GITHUB_SECRET')
	github_ignore = os.getenv('VPM_GITHUB_IGNORE') != ''
)

fn init() {
	if github_ignore {
		return
	}
	if client_id == "" {
		eprintln('Please set client id via env variable `VPM_GITHUB_CLIENT_ID`')
		panic('No github client id is specified')
	}
	if client_id == "" {
		eprintln('Please set client secret via env variable `VPM_GITHUB_SECRET`')
		panic('No github client secret is specified')
	}
}