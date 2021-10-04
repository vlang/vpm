import preprocess from 'svelte-preprocess';
import adapter from '@sveltejs/adapter-node';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: preprocess(),

	kit: {
		adapter: adapter(),
		files: {
			assets: 'static',
			hooks: 'web/hooks',
			lib: 'web/lib',
			routes: 'web/routes',
			serviceWorker: 'web/service-worker',
			template: 'web/app.html'
		},
		target: '#svelte',
	}
};

export default config;
