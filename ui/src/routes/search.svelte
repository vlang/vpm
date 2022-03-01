<script context="module" lang="ts">
	// We've choose that number because it looks nice in design
	const limit = 6;

	/** @type {import('@sveltejs/kit').Load} */
	export async function load({ params, fetch, session, stuff }) {
		const q = params.q || '';
		const user = params.user || '';
		const offset = params.page ? +params.page * limit : 0;
		const response = await fetch(`/api/search?q=${q}&user=${user}&offset=${offset}&limit=${limit}`);

		return {
			status: response.status,
			props: {
				pkgs: response.ok && (await response.json())
			}
		};
	}
</script>

<script lang="ts">
	import type Package from '$lib/types/package';

	export let pkgs: Package[];
</script>

{@html pkgs}
