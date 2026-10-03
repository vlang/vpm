/** @type {import('tailwindcss').Config} */

// Palette aligned with the V website (vlang/website, static/app.css) so vpm and
// vlang.io read as one product.
//
// These are build-time literals, which is enough for a single dark theme but
// does not allow switching at runtime: a second theme would mean moving the
// values to CSS custom properties on :root and pointing these names at them.
// `static/css/prism.css` is not processed by Tailwind, so it necessarily
// repeats two of these values; keep the two files in step by hand.
//
// Names are semantic roles, not literal colours:
// `accent` is a *light* blue meant for dark backgrounds, which is why text on
// top of it must be `on-accent` (dark ink) and never white — white on accent
// measures 1.6:1, far below the 4.5:1 WCAG AA threshold.
module.exports = {
    content: ["./templates/**/*.{html,js}"],
    theme: {
        colors: {
            // Backgrounds, from furthest back to closest to the reader.
            bg: "#090b0f",
            surface: "#101318",
            raised: "#15191f",

            // `line` is decorative separation only (1.3:1 on surface).
            // Anything that must be *identified* by its outline — form fields,
            // focus rings — uses `control-border`, which clears the 3:1
            // non-text threshold on all three backgrounds: 3.79:1 on raised,
            // 4.00:1 on surface, 4.23:1 on bg. Fields sit on `raised`, which
            // is the tightest of the three.
            line: "#252a32",
            "control-border": "#6b7585",

            fg: "#edf0f5",
            muted: "#939ba9",

            accent: {
                DEFAULT: "#a9cefa",
                strong: "#c0d9f8",
                dim: "#8fb4e0",
            },
            "on-accent": "#112034",

            danger: "#ff6b8b",
            "on-danger": "#2a0810",
            success: "#3ddc97",

            // Literal colours keep their literal meaning.
            white: "#FFFFFF",
            transparent: "#00000000",
        },
        fontFamily: {
            sans: [
                '"DM Sans"',
                "Inter",
                '"Segoe UI"',
                "BlinkMacSystemFont",
                "-apple-system",
                "Roboto",
                "Arial",
                "sans-serif",
            ],
            mono: [
                '"IBM Plex Mono"',
                "ui-monospace",
                "SFMono-Regular",
                "Menlo",
                "Consolas",
                "monospace",
            ],
        },
        // A package registry is a dense list, not a landing page: the website's
        // 19.5px body and 85px section rhythm would push results below the
        // fold. Same typeface and scale ratios, tighter steps.
        fontSize: {
            tiny: ["0.8125rem", { lineHeight: "1.125rem" }],
            small: ["0.9375rem", { lineHeight: "1.5rem" }],
            medium: ["1.125rem", { lineHeight: "1.75rem" }],
            large: ["1.5rem", { lineHeight: "2rem" }],
            "display-medium": ["2rem", { lineHeight: "2.375rem" }],
            "display-large": ["2.75rem", { lineHeight: "3rem" }],
        },
        extend: {
            width: {
                page: "73.75rem",
                // The site runs its header wider than its content: 1344 vs 1184.
                header: "84rem",
            },
            borderRadius: {
                DEFAULT: "7px",
                lg: "10px",
            },
        },
    },
    plugins: [
        require('@tailwindcss/typography'),
    ]
};
