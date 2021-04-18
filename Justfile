
@default: dev-build dev-server


# 🛠

@clean:
  rm -rf build
  mkdir -p build


@dev-build: html translate-schemas elm-dev javascript



# Pieces
# ======

@elm-dev:
  elm make src/Application/Main.elm --output=build/application.js --debug


@html:
  mkdir -p build/ingredients/

  cp src/Html/Application.html build/index.html
  cp src/Html/Application.html build/ingredients/index.html


@javascript:
  cp src/Javascript/index.js build/index.js


@translate-schemas:
  mkdir -p src/Generated
  quicktype -s schema -o src/Generated/Ingredient.elm --module Ingredient src/Schemas/Dawn/Ingredient.json
  quicktype -s schema -o src/Generated/Recipe.elm --module Recipe src/Schemas/Dawn/Recipe.json



# Development
# ===========

@dev-server:
	echo "🤵  Putting up a server for ya"
	echo "http://localhost:8005"
	devd --quiet build --port=8005 --all
