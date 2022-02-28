module Page exposing (..)

import Ingredients.Page as Ingredients
import Meals.Page as Meals
import Nourishments.Page as Nourishments
import Url exposing (Url)



-- 🌱


type Page
    = Index
      --
    | Ingredients Ingredients.Page
    | Nourishments Nourishments.Page
    | Meals Meals.Page



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
        -- Meals
        -----------------------------------------
        Meals (Meals.Detail { uuid }) ->
            "/meals/" ++ Url.percentEncode uuid ++ "/"

        Meals (Meals.Edit { uuid }) ->
            "/meals/" ++ Url.percentEncode uuid ++ "/edit/"

        Meals Meals.Index ->
            "/meals/"

        Meals (Meals.New _) ->
            "/meals/add/"

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
