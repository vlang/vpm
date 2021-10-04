module dto

pub struct CreateVersionRequest {
pub:
	package_id  int    [json: packageId]
	release_url string [json: releaseUrl]
}
