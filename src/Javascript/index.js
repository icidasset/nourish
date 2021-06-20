import * as webnative from "webnative"
import * as webnativeElm from "webnative-elm"

import { Elm } from "../Application/Main.elm"

const wn = webnative


// App
// ===

const app = Elm.Main.init({})



// Webnative
// =========

let fileSystem


webnativeElm.setup({
  app,
  webnative,

  getFs: () => fileSystem
})


webnative.initialise({
  permissions: {
    app: {
      name: "Nourish",
      creator: "icidasset"
    }
  }

}).then(async state => {
  switch (state.scenario) {

    case wn.Scenario.AuthSucceeded:
      if (state.fs) await copyOverTempFilesIfNeeded(state.fs)

    case wn.Scenario.Continuation:
      fileSystem = state.fs
      break;

    default:
      fileSystem = await loadTemporaryFileSystem()
      break;

  }

  window.fs = fileSystem

  app.ports.initialised.send({
    authenticatedUsername: await webnative.authenticatedUsername()
  })

}).catch(err => {
  switch (err) {
    case wn.InitialisationError.InsecureContext:
      console.error("Please load the app on HTTPS")

    case wn.InitialisationError.UnsupportedBrowser:
      console.error("Unsupported browser, or browser mode.")
  }

})



// TEMPORARY
// =========

const TMP_KEY =
  "temporary_filesystem_cid"

const TMP_OPTS = {
  localOnly: true,
  permissions: {
    fs: {
      private: [ webnative.path.root() ],
      public: [ webnative.path.root() ]
    }
  }
}


async function copyOverTempFilesIfNeeded(userFs) {
  const ingredientsPath = userFs.appPath("Ingredients.json")

  // Check existance
  const filesExist = await userFs.exists(ingredientsPath)
  if (filesExist) return

  // Load temp filesystem
  const tempFs = await loadTemporaryFileSystem()
  if (!tempFs) return

  // Copy files
  await usersFs.write(
    ingredientsPath,
    await tempFs.cat(ingredientsPath)
  )
}


async function loadTemporaryFileSystem() {
  const cid = localStorage.getItem(TMP_KEY)

  const fs = cid
    ? await webnative.fs.fromCID(cid, TMP_OPTS)
    : await webnative.fs.empty(TMP_OPTS);

  fs.publish = async function() {
    localStorage.setItem(TMP_KEY, await this.root.put())
  }

  if (!cid) {
    fs.publish()
  }

  return fs
}
