module Ingredients.State exposing (..)

import Ingredient
import Ingredients.Page
import Json.Decode as Decode
import Page exposing (Page(..))
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return


add : Ingredients.Page.NewContext -> Manager
add context =
    -- TODO
    Return.singleton


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


loadedIngredients : { json : String } -> Manager
loadedIngredients { json } model =
    case Decode.decodeString (Decode.list Ingredient.ingredient) json of
        Ok ingredients ->
            model.userData
                |> (\u -> { u | ingredients = Success ingredients })
                |> (\u -> { model | userData = u })
                |> Return.singleton

        Err _ ->
            -- TODO
            Return.singleton model
