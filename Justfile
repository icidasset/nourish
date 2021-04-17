
@default: translate-schemas


@translate-schemas:
  mkdir -p src/Generated
  quicktype -s schema -o src/Generated/Ingredient.elm --module Ingredient src/Schemas/Dawn/Ingredient.json
  quicktype -s schema -o src/Generated/Recipe.elm --module Recipe src/Schemas/Dawn/Recipe.json
