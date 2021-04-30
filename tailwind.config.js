const colors = require("tailwindcss/colors")


module.exports = {
  mode: "jit",
  darkMode: "media",

  //
  purge: [
    "src/Application/**/*.elm"
  ],

  //
  theme: {
    extend: {
      colors: {
        gray: colors.warmGray,
      }
    },
  },

  //
  variants: {
    extend: {},
  }

}
