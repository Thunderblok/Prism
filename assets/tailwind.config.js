// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/prism_web.ex",
    "../lib/prism_web/**/*.*ex",
    "../storybook/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
        'glow-cyan': '#00ffff',
        'glow-pink': '#ff00ff',
        'glow-orange': '#ff6600',
        'dark-bg': '#0a0a0a',
        'neon-green': '#00ff00',
        'electric-blue': '#0099ff',
      },
      fontFamily: {
        'mono': ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
      animation: {
        'pulse-glow': 'pulse-glow 2s ease-in-out infinite alternate',
        'neon-flicker': 'neon-flicker 0.15s ease-in-out infinite alternate',
      },
      keyframes: {
        'pulse-glow': {
          'from': { textShadow: '0 0 4px #0ff, 0 0 8px #0ff, 0 0 12px #0ff' },
          'to': { textShadow: '0 0 6px #0ff, 0 0 12px #0ff, 0 0 18px #0ff, 0 0 24px #0ff' }
        },
        'neon-flicker': {
          '0%, 100%': { opacity: '1' },
          '50%': { opacity: '0.8' }
        }
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("daisyui"),
    
    // LiveView loading states
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ],
  
  // DaisyUI Configuration
  daisyui: {
    themes: [
      {
        thunderprism: {
          "primary": "#00ffff",        // glow-cyan
          "secondary": "#ff00ff",      // glow-pink  
          "accent": "#ff6600",         // glow-orange
          "neutral": "#1a1a1a",        // dark neutral
          "base-100": "#0a0a0a",       // dark-bg
          "base-200": "#111111",       // slightly lighter
          "base-300": "#1a1a1a",       // neutral dark
          "info": "#0099ff",           // electric-blue
          "success": "#00ff00",        // neon-green
          "warning": "#ffff00",        // neon yellow
          "error": "#ff0066",          // neon red
        }
      },
      "dark", // fallback theme
    ],
    base: true,
    styled: true,
    utils: true,
  }
}
