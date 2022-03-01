<script>
	export let width = 24;
	export let height = 24;
	export let ariaLabel = 'Download';
</script>

<svg
	role="img"
	xmlns="http://www.w3.org/2000/svg"
	{width}
	{height}
	aria-label={ariaLabel}
	fill="none"
	viewBox="0 0 24 24"
>
	<path
		stroke="currentColor"
		stroke-linecap="round"
		stroke-linejoin="round"
		stroke-width="2"
		d="M12 2L2 7l10 5 10-5-10-5z"
		clip-rule="evenodd"
	/>
	<path
		stroke="currentColor"
		stroke-linecap="round"
		stroke-linejoin="round"
		stroke-width="2"
		d="M2 17l10 5 10-5M2 12l10 5 10-5"
	/>
</svg>
