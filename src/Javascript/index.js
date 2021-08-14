import * as webnative from "webnative"
import * as webnativeElm from "webnative-elm"

import { Elm } from "../Application/Main.elm"

const wn = webnative


// App
// ===

const app = Elm.Main.init({
  flags: {
    seeds: Array.from(
      crypto.getRandomValues(new Uint32Array(4))
    )
  }
})



// Webnative
// =========

let fileSystem


webnativeElm.setup({
  app,
  webnative,

  getFs: () => fileSystem
})


webnative.initialise({
  loadFileSystem: false,
  permissions: {
    app: {
      name: "Nourish",
      creator: "icidasset"
    }
  }

}).then(async state => {
  switch (state.scenario) {

    case wn.Scenario.AuthSucceeded:
      fileSystem = await copyOverTempFilesIfNeeded(state.permissions)

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


async function copyOverTempFilesIfNeeded(permissions) {
  const tempFs = await loadTemporaryFileSystem()
  if (!tempFs) return webnative.loadFileSystem(permissions)

  // Get all data from the temporary filesystem
  const ingredientsPath = tempFs.appPath("Ingredients.json")
  const nourishmentsPath = tempFs.appPath("Nourishments.json")

  const ingredients = await tempFs.cat(ingredientsPath)
  const nourishments = await tempFs.cat(nourishmentsPath)

  // Load user's filesystem
  const userFs = await webnative.loadFileSystem(permissions)

  // Check existance
  const filesExist =
    await userFs.exists(ingredientsPath) ||
    await userFs.exists(nourishmentsPath)

  if (filesExist) return userFs

  // Copy files
  await usersFs.write(ingredientsPath, ingredients)
  await usersFs.write(nourishmentsPath, nourishments)

  // Remove temporary filesystem
  removeTemporaryFileSystem()

  // Fin
  return userFs
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


async function removeTemporaryFileSystem() {
  localStorage.removeItem(TMP_KEY)
}
