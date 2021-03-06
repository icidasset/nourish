const colors = require("tailwindcss/colors")
const plugin = require("tailwindcss/plugin")
const kit = require("@fission-suite/kit")


module.exports = {
  darkMode: "media",


  content: [
    "src/Application/**/*.elm",
    "src/Library/**/*.elm",
    ...kit.tailwindPurgeList()
  ],


  theme: {
    extend: {

      colors: {
        blue: colors.sky,
        gray: colors.stone,
        green: colors.green,
        lime: colors.lime,
      },

      fontFamily: {
        body: [ "Inter" ],
        display: [ "Caveat" ]
      },

      fontSize: kit.fontSizes

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
          fontStyle: "normal",
          fontWeight: "100 1000",
          src: `url("/Fonts/Inter-VariableFont_roman.woff2") format("woff2")`
        }
      })

      addBase({
        '@font-face': {
          fontFamily: "Inter",
          fontStyle: "italic",
          fontWeight: "100 1000",
          src: `url("/Fonts/Inter-VariableFont_italic.woff2") format("woff2")`
        }
      })
    })

  ]

}
