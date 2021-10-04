module Page exposing (..)

import Ingredients.Page as Ingredients
import Nourishments.Page as Nourishments
import Schedule.Page as Schedule
import Url exposing (Url)



-- 🌱


type Page
    = Index
      --
    | Ingredients Ingredients.Page
    | Nourishments Nourishments.Page
    | Schedule Schedule.Page



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

        Ingredients (Ingredients.Edit { uuid }) ->
            "/ingredients/" ++ Url.percentEncode uuid ++ "/edit/"

        Ingredients (Ingredients.Index _) ->
            "/ingredients/"

        Ingredients (Ingredients.New _) ->
            "/ingredients/new/"

        -----------------------------------------
        -- Nourishments
        -----------------------------------------
        Nourishments (Nourishments.Detail { uuid }) ->
            "/foods/" ++ Url.percentEncode uuid ++ "/"

        Nourishments (Nourishments.Edit { uuid }) ->
            "/foods/" ++ Url.percentEncode uuid ++ "/edit/"

        Nourishments (Nourishments.Index _) ->
            "/foods/"

        Nourishments (Nourishments.New _) ->
            "/foods/new/"

        -----------------------------------------
        -- Schedule
        -----------------------------------------
        Schedule Schedule.Index ->
            "/menu/"

        Schedule (Schedule.New _) ->
            "/menu/add/"
