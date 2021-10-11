module Meals.Wnfs exposing (..)

import Json.Encode as Encode
import Meal exposing (Meal)
import Radix exposing (..)
import Tag exposing (Tag(..))
import UserData
import Webnative
import Webnative.Path
import Wnfs


save : List Meal -> Webnative.Request
save meals =
    Wnfs.writeUtf8
        (Wnfs.AppData appPermissions)
        { path = UserData.mealsPath
        , tag = Tag.toString SavedMeals
        }
        (meals
            |> Encode.list Meal.encodeMeal
            |> Encode.encode 0
        )
