export type Package = {
	id: number,
	author_id: number,
	gh_repo_id: number,

	name: string,
	description: string,
	documentation: string,
	repository: string,

	stars: number,
	downloads: number,
	downloaded_at: string,

	updated_at: string,
	created_at: string,
}

export default Package;
