module Ingredients.Wnfs exposing (..)

import Ingredient exposing (Ingredient)
import Json.Encode as Encode
import Radix exposing (..)
import Tag exposing (Tag(..))
import Webnative
import Webnative.Path
import Wnfs


save : List Ingredient -> Webnative.Request
save ingredients =
    Wnfs.writeUtf8
        (Wnfs.AppData appPermissions)
        { path = Webnative.Path.file [ "Ingredients.json" ]
        , tag = Tag.toString SavedIngredients
        }
        (ingredients
            |> Encode.list Ingredient.encodeIngredient
            |> Encode.encode 0
        )
