/** @type {import('@sveltejs/kit').RequestHandler} */
export async function get() {
	// Redirecting to search page
	return {
		status: 302,
		redirect: "/search"
	};
};
