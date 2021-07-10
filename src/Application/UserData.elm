module UserData exposing (..)

import Ingredient exposing (Ingredient)
import List.Extra as List
import RemoteData exposing (RemoteData(..))



-- 🌱


type alias UserData =
    { ingredients : RemoteData String (List Ingredient)
    , userName : Maybe String
    }


empty =
    { ingredients = Loading
    , userName = Nothing
    }



-- INGREDIENTS


addIngredient : UserData -> Ingredient -> UserData
addIngredient userData ingredient =
    mapIngredients
        (\list -> list ++ [ ingredient ])
        userData


findIngredient : { uuid : String } -> UserData -> Maybe Ingredient
findIngredient { uuid } { ingredients } =
    ingredients
        |> RemoteData.withDefault []
        |> List.find (.uuid >> (==) uuid)


mapIngredients : (List Ingredient -> List Ingredient) -> UserData -> UserData
mapIngredients fn ({ ingredients } as userData) =
    { userData | ingredients = RemoteData.map fn ingredients }


removeIngredient : UserData -> { uuid : String } -> UserData
removeIngredient userData { uuid } =
    mapIngredients
        (List.filter
            (.uuid >> (/=) uuid)
        )
        userData
