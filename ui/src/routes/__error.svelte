<script context="module">
	/** @type {import('@sveltejs/kit').ErrorLoad} */
	export function load({ error, status }) {
		return {
			props: {
				status: status,
				title: error.message
			}
		};
	}
</script>

<script>
	export let status;
	export let title;
</script>

<div>
	<h1 class="text-primary">{status}</h1>
	<p>{title}</p>

	<a href="/">Go to main page</a>
</div>
