/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/main/webapp/**/*.jsp",   // semua file JSP
    "./src/main/webapp/**/*.html",  // kalau ada HTML
    "./src/main/webapp/**/*.js",    // kalau ada JS
  ],
  
  theme: {
    extend: {},
    // screens: {
    //   'sm': '640px',
    //   'md': '768px',
    //   'lg': '1024px',
    //   'xl': '1280px',
    // },
  },
  plugins: [],
}
