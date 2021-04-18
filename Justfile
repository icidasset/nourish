
@default: translate-schemas


# Pieces
# ======

@elm-dev:
  elm make src/Application/Main.elm --output=build/application.js


@translate-schemas:
  mkdir -p src/Generated
  quicktype -s schema -o src/Generated/Ingredient.elm --module Ingredient src/Schemas/Dawn/Ingredient.json
  quicktype -s schema -o src/Generated/Recipe.elm --module Recipe src/Schemas/Dawn/Recipe.json
