<script lang="ts">
	import ChevronRight from '$lib/icons/ChevronRight.svelte';
	import Clock from '$lib/icons/Clock.svelte';
	import Star from '$lib/icons/Star.svelte';
	import type Package from '$lib/types/package';

	export let Package: Package;
</script>

<div class="basis-[5.625rem] flex gap-4 items-center">
	<div class="min-w-0 flex-auto">
		<a
			class="mb-1 block font-bold text-medium text-primary overflow-hidden whitespace-nowrap overflow-ellipsis"
			href="/package/{Package.name}"
		>
			{Package.name}
		</a>
		<p class="mb-2 block text-small text-sub overflow-hidden whitespace-nowrap overflow-ellipsis">
			{Package.description}
		</p>
		<div class="flex gap-4 items-center text-sub overflow-hidden">
			<div class="flex gap-2 whitespace-nowrap"><Clock /> 1 day ago</div>
			<div class="flex gap-2 whitespace-nowrap"><Star /> 1920</div>
		</div>
	</div>
	<a class="text-primary" href="/package/{Package.name}" tabindex="-1">
		<ChevronRight />
	</a>
</div>

<!-- 🍆 { suck 🍌 } -->
