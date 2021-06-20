module Tag exposing (..)


type Tag
    = LoadedIngredients
    | SavedIngredients
    | Untagged


fromString : String -> Result String Tag
fromString string =
    case string of
        "LoadedIngredients" ->
            Ok LoadedIngredients

        "SavedIngredients" ->
            Ok SavedIngredients

        "Untagged" ->
            Ok Untagged

        _ ->
            Err "Invalid tag"


toString : Tag -> String
toString tag =
    case tag of
        LoadedIngredients ->
            "LoadedIngredients"

        SavedIngredients ->
            "SavedIngredients"

        Untagged ->
            "Untagged"
