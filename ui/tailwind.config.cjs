const config = {
	content: ['./src/**/*.{html,js,svelte,ts}'],

	theme: {
		colors: {
			primary: '#559FFF',
			general: "#161616",
			grey: '#B6B6B6',
			'dark-grey': '#626262',
			'off-white': '#F0F0F0',
			sub: '#7A7A7A',
			night: '#161616',
			disabled: "#D9D9D9",
			white: "#FFFFFF",

			success: '#00BA88',
			error: '#FA3C6A',

			base: "#F7F7F7",

			transparent: "#00000000",
		},
		fontFamily: {
			sans: ['Mulish', 'Inter', 'Roboto', '"Noto Sans"', '"Open Sans"', '"Helvetica Neue"', '"Segoe UI"',
				'BlinkMacSystemFont', '-apple-system', 'Cantarell', 'Arial', 'sans-serif']
		},
		fontSize: {
			small: ['1', {
				lineHeight: '1.5rem',
			}],
			medium: ['1.25rem', {
				lineHeight: '1.875rem',
			}],
			large: ['1.5625rem', {
				lineHeight: '2.34375rem',
			}],
			'display-medium': ['2.375rem', {
				lineHeight: '2.375rem',
			}],
			'display-large': ['3rem', {
				lineHeight: '3rem',
			}],
		},
		extend: {
			width: {
				'page': '73.75rem',
			}
		},
	},

	plugins: []
};

module.exports = config;
