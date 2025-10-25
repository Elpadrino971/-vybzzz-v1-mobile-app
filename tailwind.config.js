module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'vybzzz-purple': '#6B2D9E',
        'vybzzz-orange': '#FFA500',
        'vybzzz-cream': '#FFF8DC',
        'vybzzz-dark': '#0A0A0A',
      },
      backgroundImage: {
        'vybzzz-gradient': 'linear-gradient(135deg, #6B2D9E 0%, #FFA500 100%)',
      },
    },
  },
  plugins: [],
}
