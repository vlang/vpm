<script>
	import Login from '$lib/components/Login.svelte';
	import Logo from '$lib/icons/Logo.svelte';
	import Search from '$lib/icons/Search.svelte';
</script>

<header
	class="flex-shrink-0 h-28 flex justify-center items-center bg-white border-b-2 border-solid border-off-white"
>
	<div class="px-4 w-page h-16 flex gap-4 justify-between">
		<div class="flex-1 flex items-center">
			<a href="/">
				<Logo />
			</a>
		</div>
		<form
			class="flex basis-[36.25rem] rounded-2xl focus-within:outline bg-off-white"
			action="/search"
		>
			<label class="flex-1 px-5 py-4 box-border flex gap-4 items-center text-grey">
				<Search />
				<input
					class="flex-1 appearance-none focus:border-0 focus:outline-none bg-transparent"
					name="q"
					type="search"
					placeholder="Search"
					autocomplete="on"
					pattern={'[A-Za-z0-9-.]{(1, 100)}'}
					title="Must match rules of github repo naming"
				/>
			</label>
		</form>
		<div class="flex-1 flex justify-end items-center">
			<Login />
		</div>
	</div>
</header>

<style>
	input::-webkit-search-cancel-button {
		filter: grayscale(1);
	}
</style>
