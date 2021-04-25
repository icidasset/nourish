import { execSync } from "child_process"
import elmPlugin from "vite-plugin-elm"


const elm = elmPlugin()


module.exports = {
  plugins: [
    {
      ...elm,
      transform: (...args) => elm.transform(...args).then(r => {
        if (r) console.log(execSync(`just css`).toString())
        return r
      })
    }
  ],

  publicDir: "src/Static/",

  // Build
  build: {
    minify: "esbuild",
    outDir: "build"
  }
}
