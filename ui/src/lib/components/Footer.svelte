<script>
	import Github from '$lib/icons/social/Github.svelte';
	import Discord from '$lib/icons/social/Discord.svelte';
	import Twitter from '$lib/icons/social/Twitter.svelte';
</script>

<footer
	class="flex-shrink-0 h-28 flex justify-center items-center bg-white border-t-2 border-solid border-off-white"
>
	<div class="px-4 w-page h-16 flex gap-4 justify-betwee font-bold text-medium">
		<div class="flex-1 flex gap-4 justify-start items-center" href="/">
			<a
				class="text-sub hover:text-primary hover:no-underline"
				href="https://github.com/Terisback/vpm/blob/master/docs/API.md">API</a
			>
			<a
				class="text-sub hover:text-primary hover:no-underline"
				href="https://github.com/Terisback/vpm/blob/master/docs/API.md">Docs</a
			>
		</div>

		<div class="flex-1 flex gap-8 justify-center items-center">
			<a
				class="text-sub hover:text-primary hover:no-underline"
				rel="external"
				href="https://twitter.com/vlang"><Twitter /></a
			>
			<a
				class="text-sub hover:text-primary hover:no-underline"
				rel="external"
				href="https://github.com/vlang"><Github /></a
			>
			<a
				class="text-sub hover:text-primary hover:no-underline"
				rel="external"
				href="https://discord.gg/vlang"><Discord /></a
			>
		</div>

		<div class="flex-1 flex gap-4 justify-end items-center">
			<a
				class="text-sub hover:text-primary hover:no-underline"
				rel="external"
				href="https://modules.vlang.io">vlib</a
			>
			<a
				class="text-sub hover:text-primary hover:no-underline"
				rel="external"
				href="https://vlang.io">vlang.io</a
			>
		</div>
	</div>
</footer>
