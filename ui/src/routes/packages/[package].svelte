<script context="module" lang="ts">
	/** @type {import('@sveltejs/kit').Load} */
	export async function load({ params, fetch, session, stuff }) {
		const response = await fetch(`/api/packages/${params.slug}`);

		return {
			status: response.status,
			props: {
				pkg: response.ok && (await response.json())
			}
		};
	}
</script>

<script lang="ts">
	import type Package from '$lib/types/package';

	export let pkg: Package;
</script>

{pkg.name}
