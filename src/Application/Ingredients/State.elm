module Ingredients.State exposing (..)

import Ingredients.Page
import Page exposing (Page(..))
import Radix exposing (..)
import Return


gotContextForIngredientsIndex : Ingredients.Page.IndexContext -> Manager
gotContextForIngredientsIndex indexContext model =
    (case model.page of
        Ingredients (Ingredients.Page.Index _) ->
            Ingredients (Ingredients.Page.Index indexContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


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
