import * as webnative from "webnative"
import * as webnativeElm from "webnative-elm"
import { CID } from "multiformats/cid"
import { appDataPath } from "webnative/ucan/permissions.js"

import { Elm } from "../Application/Main.elm"

const wn = webnative


// App
// ===

const app = Elm.Main.init({
  flags: {
    currentTime: Date.now(),
    seeds: Array.from(
      crypto.getRandomValues(new Uint32Array(4))
    )
  }
})



// Webnative
// =========

let fileSystem


const APP_PERMISSIONS = {
  name: "Nourish",
  creator: "icidasset"
}


webnativeElm.setup({
  app,
  webnative,

  getFs: () => fileSystem
})


webnative.initialise({
  loadFileSystem: false,
  permissions: {
    app: APP_PERMISSIONS
  }

}).then(async state => {
  switch (state.scenario) {

    case wn.Scenario.AuthSucceeded:
      fileSystem = await copyOverTempFilesIfNeeded(state.permissions)

    case wn.Scenario.Continuation:
      fileSystem = await webnative.loadFileSystem(state.permissions)
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
  console.error(err)

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
  console.log("🚀 Copying over temporary data")

  // Get all data from the temporary filesystem
  const base = appDataPath(APP_PERMISSIONS)
  const ingredientsPath = webnative.path.combine(
    base,
    webnative.path.file("Ingredients.json")
  )

  const mealsPath = webnative.path.combine(
    base,
    webnative.path.file("Meals.json")
  )

  const nourishmentsPath = webnative.path.combine(
    base,
    webnative.path.file("Nourishments.json")
  )

  const ingredients = await tempFs.cat(ingredientsPath).catch(_ => "[]")
  const meals = await tempFs.cat(mealsPath).catch(_ => "[]")
  const nourishments = await tempFs.cat(nourishmentsPath).catch(_ => "[]")

  // Load user's filesystem
  const userFs = await webnative.loadFileSystem(permissions)

  // Check existance
  const filesExist =
    await userFs.exists(ingredientsPath) ||
    await userFs.exists(mealsPath) ||
    await userFs.exists(nourishmentsPath)

  // Copy files if needed
  if (!filesExist) {
    await userFs.write(ingredientsPath, ingredients)
    await userFs.write(mealsPath, meals)
    await userFs.write(nourishmentsPath, nourishments)
    await userFs.publish()
  }

  // Remove temporary filesystem
  removeTemporaryFileSystem()

  // Fin
  console.log("✅ Data copy succeeded")
  return userFs
}


async function loadTemporaryFileSystem() {
  const cid = localStorage.getItem(TMP_KEY)

  const fs = cid
    ? await webnative.fs.fromCID(CID.parse(cid), TMP_OPTS)
    : await webnative.fs.empty(TMP_OPTS);

  fs.publish = async function() {
    const c = await this.root.put()
    localStorage.setItem(TMP_KEY, c.toString())
    return c
  }

  if (!cid) {
    fs.publish()
  }

  return fs
}


async function removeTemporaryFileSystem() {
  localStorage.removeItem(TMP_KEY)
}
