module Page exposing (..)

import Ingredients.Page as Ingredients
import Nourishments.Page as Nourishments
import Url exposing (Url)



-- 🌱


type Page
    = Index
      --
    | Ingredients Ingredients.Page
    | Nourishments Nourishments.Page



-- 🛠


toString : Page -> String
toString page =
    case page of
        Index ->
            "/"

        -----------------------------------------
        -- Ingredients
        -----------------------------------------
        Ingredients (Ingredients.Detail { uuid }) ->
            "/ingredients/" ++ Url.percentEncode uuid ++ "/"

        Ingredients (Ingredients.Index _) ->
            "/ingredients/"

        Ingredients (Ingredients.New _) ->
            "/ingredients/new/"

        -----------------------------------------
        -- Nourishments
        -----------------------------------------
        Nourishments (Nourishments.Detail { uuid }) ->
            "/ingredients/" ++ Url.percentEncode uuid ++ "/"

        Nourishments (Nourishments.Index _) ->
            "/ingredients/"

        Nourishments (Nourishments.New _) ->
            "/ingredients/new/"
