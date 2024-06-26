// See the Tailwind default theme values here:
// https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  // Opt-in to TailwindCSS future changes
  future: {
  },

  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
    require('@tailwindcss/typography'),
  ],

  // Purge unused TailwindCSS styles
  purge: {
    enabled: ["production", "staging"].includes(process.env.NODE_ENV),
    content: [
      './**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
    ],
    options: {
      safelist: [
        "h-7",
        "w-7"
      ]
    }
  },

  // All the default values will be compiled unless they are overridden below
  theme: {
    // Extend (add to) the default theme in the `extend` key
    extend: {
      // Create your own at: https://javisperez.github.io/tailwindcolorshades
      colors: {
        //orange: colors.orange,
        // 'primary': {
        //   50: '#F6F7FF',
        //   100: '#EDF0FE',
        //   200: '#D2D9FD',
        //   300: '#B6C1FB',
        //   400: '#8093F9',
        //   500: '#4965F6',
        //   600: '#425BDD',
        //   700: '#2C3D94',
        //   800: '#212D6F',
        //   900: '#161E4A',
        // },
        'primary': {
          50: '#ECF7F1',
          100: '#dce6ef',
          200: '#bbcede',
          300: '#9bb5cd',
          400: '#7d9dbb',
          500: '#6086a8',
          600: '#466f94',
          700: '#2f597e',
          800: '#1a4367',
          900: '#0a2e4e',
        },
        'secondary': {
          50: '#F5FDF9',
          100: '#ECFAF4',
          200: '#CFF3E3',
          300: '#B2ECD2',
          400: '#78DDB0',
          500: '#3ECF8E',
          600: '#38BA80',
          700: '#257C55',
          800: '#1C5D40',
          900: '#133E2B',
        },
        'tertiary': {
          50: '#F7F7F8',
          100: '#EEEEF1',
          200: '#D5D5DB',
          300: '#BCBCC5',
          400: '#898A9A',
          500: '#57586E',
          600: '#4E4F63',
          700: '#343542',
          800: '#272832',
          900: '#1A1A21',
        },
        'danger': {
          50: '#FEF8F8',
          100: '#FEF2F2',
          200: '#FCDEDE',
          300: '#FACACA',
          400: '#F7A3A3',
          500: '#F37B7B',
          600: '#DB6F6F',
          700: '#924A4A',
          800: '#6D3737',
          900: '#492525',
        },
        "code-400": "#fefcf9",
        "code-600": "#3c455b",
      },
    },
    // override the default theme using the key directly
    fontFamily: {
      sans: ['Inter', ...defaultTheme.fontFamily.sans],
    },
  },
  variants: {
    borderWidth: ['responsive', 'last', 'hover', 'focus'],
  },
}
