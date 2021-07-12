module Tag exposing (..)


type
    Tag
    -----------------------------------------
    -- Ingredients
    -----------------------------------------
    = EnsureIngredients
    | LoadedIngredients
    | SavedIngredients
      -----------------------------------------
      -- Nourishments
      -----------------------------------------
    | EnsureNourishments
    | LoadedNourishments
    | SavedNourishments
      -----------------------------------------
      -- 🐚
      -----------------------------------------
    | Untagged


fromString : String -> Result String Tag
fromString string =
    case string of
        -----------------------------------------
        -- Ingredients
        -----------------------------------------
        "EnsureIngredients" ->
            Ok EnsureIngredients

        "LoadedIngredients" ->
            Ok LoadedIngredients

        "SavedIngredients" ->
            Ok SavedIngredients

        -----------------------------------------
        -- Nourishments
        -----------------------------------------
        "EnsureNourishments" ->
            Ok EnsureNourishments

        "LoadedNourishments" ->
            Ok LoadedNourishments

        "SavedNourishments" ->
            Ok SavedNourishments

        -----------------------------------------
        -- 🐚
        -----------------------------------------
        "Untagged" ->
            Ok Untagged

        _ ->
            Err "Invalid tag"


toString : Tag -> String
toString tag =
    case tag of
        -----------------------------------------
        -- Ingredients
        -----------------------------------------
        EnsureIngredients ->
            "EnsureIngredients"

        LoadedIngredients ->
            "LoadedIngredients"

        SavedIngredients ->
            "SavedIngredients"

        -----------------------------------------
        -- Nourishments
        -----------------------------------------
        EnsureNourishments ->
            "EnsureNourishments"

        LoadedNourishments ->
            "LoadedNourishments"

        SavedNourishments ->
            "SavedNourishments"

        -----------------------------------------
        -- 🐚
        -----------------------------------------
        Untagged ->
            "Untagged"
