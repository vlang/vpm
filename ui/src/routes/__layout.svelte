<script>
	import Footer from '$lib/components/Footer.svelte';
	import Header from '$lib/components/Header.svelte';
	import '../app.css';
</script>

<div class="h-screen min-h-screen flex flex-col gap-20">
	<Header />
	<div class="px-4 flex-auto flex justify-center">
		<main class="w-page flex flex-col gap-12">
			<slot />
		</main>
	</div>
	<Footer />
</div>
