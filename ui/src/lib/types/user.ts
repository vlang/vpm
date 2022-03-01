export type User = {
	id: number,
	gh_id: number,
	login: string,
	avatar: string,
	name: string,

	is_blocked: boolean,
	block_reason: string,
	is_admin: boolean,
}

export default User;
