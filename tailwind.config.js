const colors = require("tailwindcss/colors")
const plugin = require("tailwindcss/plugin")


module.exports = {
  mode: "jit",
  darkMode: "media",


  purge: [
    "src/Application/**/*.elm",
    "src/Library/**/*.elm"
  ],


  theme: {
    extend: {

      colors: {
        blue: colors.lightBlue,
        gray: colors.warmGray,
        green: colors.green,
        lime: colors.lime,
      },

      fontFamily: {
        body: [ "Inter" ],
        display: [ "Caveat" ]
      }

    },
  },


  plugins: [

    // Add custom font
    plugin(function({ addBase }) {
      addBase({
        '@font-face': {
          fontFamily: "Caveat",
          fontWeight: "100 1000",
          src: `url("/Fonts/Caveat-VariableFont_wght.woff2") format("woff2")`
        }
      })

      addBase({
        '@font-face': {
          fontFamily: "Inter",
          fontWeight: "100 1000",
          src: `url("/Fonts/Inter-VariableFont_slnt,wght.woff2") format("woff2")`
        }
      })
    })

  ]

}
