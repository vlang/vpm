<script>
	export let width = 24;
	export let height = 24;
	export let ariaLabel = 'Sun';
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
		d="M12 17a5 5 0 100-10 5 5 0 000 10z"
		clip-rule="evenodd"
	/>
	<path
		stroke="currentColor"
		stroke-linecap="round"
		stroke-linejoin="round"
		stroke-width="2"
		d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"
	/>
</svg>
