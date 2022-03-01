<script lang="ts">
	import PackageCard from '$lib/components/PackageCard.svelte';
	import Browse from '$lib/icons/Browse.svelte';
	import Plus from '$lib/icons/Plus.svelte';
	import type Package from '$lib/types/package';
	import type Tag from '$lib/types/tag';

	const pkg: Package = {
		id: 123,
		author_id: 123,
		gh_repo_id: 123,

		name: 'treplo',
		description: 'Logging lib',
		documentation: 'https://github.com/Terisback',
		repository: 'https://github.com/Terisback',

		stars: 1920,
		downloads: 20000,
		downloaded_at: '1644862063',

		updated_at: '1644862063',
		created_at: '1644862063'
	};

	const tags: Tag[] = [
		{ slug: 'web', packages: 23 },
		{ slug: 'cli', packages: 98 },
		{ slug: 'database', packages: 41 },
		{ slug: 'gamedev', packages: 48 },
		{ slug: 'graphics', packages: 4 },
		{ slug: 'wrapper', packages: 198 },
		{ slug: 'binding', packages: 56 },
		{ slug: 'parsing', packages: 3 },
		{ slug: 'http', packages: 19 },
		{ slug: 'io', packages: 69 },
		{ slug: 'http-router', packages: 3 }
	];
</script>

<div class="flex gap-4 flex-col">
	<h1 class="text-display-large font-bold">
		Package Manager for the <span class="text-primary">V</span> Language
	</h1>

	<p class="text-large text-sub">
		Instantly publish your packages and install them. Use the API to interact and find out more
		information about available packages. Become a contributor and enhance the site with your work.
	</p>
</div>

<div class="flex gap-8 items-center">
	<div class="flex gap-4">
		<a href="/search" class="button text-white hover:no-underline bg-primary flex gap-2">
			<Browse /> Browse packages
		</a>
		<a href="/submit" class="button text-white hover:no-underline bg-primary flex gap-2">
			<Plus /> Submit package
		</a>
	</div>
	<span> 232 packages </span>
</div>

<div>
	<h2 class="mb-4 text-large font-bold">Popular tags</h2>
	<div class="flex flex-wrap gap-2 panel">
		{#each tags as tag}
			<a
				class="px-4 py-2 rounded-lg whitespace-nowrap font-bold text-dark-grey bg-off-white"
				href="/search?tags={tag.slug}"
			>
				{tag.slug}<sup class="ml-[0.065rem] leading-[0] text-[0.625rem] font-bold"
					>{tag.packages}</sup
				>
			</a>
		{/each}
	</div>
</div>

<div>
	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 justify-between">
		<div class="flex-auto">
			<h2 class="mb-4 text-large font-bold">New packages</h2>
			<div class="flex flex-col gap-4 panel">
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
			</div>
		</div>
		<div class="flex-auto">
			<h2 class="mb-4 text-large font-bold">Most downloaded</h2>
			<div class="flex flex-col gap-4 panel">
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
			</div>
		</div>
		<div class="flex-auto">
			<h2 class="mb-4 text-large font-bold">Recently updated</h2>
			<div class="flex flex-col gap-4 panel">
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
				<PackageCard Package={pkg} />
			</div>
		</div>
	</div>
</div>
