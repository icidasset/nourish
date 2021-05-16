module Ingredients.State exposing (..)

import Ingredients.Page
import Page exposing (Page(..))
import Radix exposing (..)
import Return


gotContextForNewIngredient : Ingredients.Page.NewContext -> Manager
gotContextForNewIngredient newContext model =
    (case model.page of
        Ingredients (Ingredients.Page.New _) ->
            Ingredients (Ingredients.Page.New newContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton
