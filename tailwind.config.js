/** @type {import('tailwindcss').Config} */

// Palette aligned with the V website (vlang/website, static/app.css) so vpm and
// vlang.io read as one product.
//
// Every chromatic role points at a CSS custom property defined in
// `static/css/index.css`, where the light and dark values live side by side.
// That is also what lets `static/css/prism.css`, which Tailwind never sees,
// carry one set of structural rules for both themes.
//
// Names are semantic roles, not literal colours:
// `accent` is a *light* blue meant for dark backgrounds, which is why text on
// top of it must be `on-accent` (dark ink) and never white — white on accent
// measures 1.6:1, far below the 4.5:1 WCAG AA threshold.
module.exports = {
    content: ["./templates/**/*.{html,js}"],
    theme: {
        // Every chromatic role points at a CSS custom property, so the two
        // themes are one set of values redefined in `index.css` rather than a
        // second build. No `/alpha` modifier is used anywhere in this project,
        // which is what makes whole-colour variables viable here.
        colors: {
            bg: "var(--c-bg)",
            surface: "var(--c-surface)",
            raised: "var(--c-raised)",

            line: "var(--c-line)",
            "control-border": "var(--c-control-border)",

            fg: "var(--c-fg)",
            "fg-strong": "var(--c-fg-strong)",
            muted: "var(--c-muted)",

            accent: {
                DEFAULT: "var(--c-accent)",
                strong: "var(--c-accent-strong)",
            },
            "on-accent": "var(--c-on-accent)",

            danger: "var(--c-danger)",
            "on-danger": "var(--c-on-danger)",
            success: "var(--c-success)",

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
