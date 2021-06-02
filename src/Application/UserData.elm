module UserData exposing (..)

import Ingredient exposing (Ingredient)
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
