module Ingredients.Wnfs exposing (..)

import Ingredient exposing (Ingredient)
import Json.Encode as Encode
import Radix exposing (..)
import Tag exposing (Tag(..))
import UserData
import Webnative
import Webnative.Path
import Wnfs


save : List Ingredient -> Webnative.Request
save ingredients =
    Wnfs.writeUtf8
        (Wnfs.AppData appPermissions)
        { path = UserData.ingredientsPath
        , tag = Tag.toString SavedIngredients
        }
        (ingredients
            |> Encode.list Ingredient.encodeIngredient
            |> Encode.encode 0
        )
