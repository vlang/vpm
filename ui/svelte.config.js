import adapter from '@sveltejs/adapter-node';
// import adapter from '@sveltejs/adapter-auto';
import preprocess from 'svelte-preprocess';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: [
		preprocess({
			postcss: true
		})
	],

	kit: {
		adapter: adapter({ out: 'build' }),
		vite: {
			envPrefix: "VPM_",
		},
	}
};

export default config;
