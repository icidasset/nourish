module Tag exposing (..)


type Tag
    = LoadedIngredients


fromString : String -> Result String Tag
fromString string =
    case string of
        "LoadedIngredients" ->
            Ok LoadedIngredients

        _ ->
            Err "Invalid tag"


toString : Tag -> String
toString tag =
    case tag of
        LoadedIngredients ->
            "LoadedIngredients"
