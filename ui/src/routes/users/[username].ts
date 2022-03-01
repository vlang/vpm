/** @type {import('@sveltejs/kit').RequestHandler} */
export async function get({ params }) {
	return {
		status: 302,
		redirect: `/search?user=${params.username}`
	};
};
