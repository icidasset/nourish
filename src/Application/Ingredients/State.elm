module Ingredients.State exposing (..)

import Ingredient
import Ingredients.Page as Ingredients
import Ingredients.Wnfs
import Json.Decode as Decode
import Json.Decode.Ext as Decode
import MultiSelect
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import String.Extra as String
import UUID
import UserData


add : Ingredients.NewContext -> Manager
add context model =
    let
        ( uuid, newSeeds ) =
            UUID.step model.seeds
    in
    { uuid = UUID.toString uuid

    --
    , emoji = String.nonBlank context.emoji
    , minerals = []
    , name = String.trim context.name
    , seasonality = []
    , stores = []
    , tags = MultiSelect.selected context.tags
    , vitamins = []
    }
        |> UserData.addIngredient model.userData
        |> (\u ->
                return
                    { model
                        | page = Ingredients Ingredients.index
                        , seeds = newSeeds
                        , userData = u
                    }
                    (u.ingredients
                        |> RemoteData.withDefault []
                        |> Ingredients.Wnfs.save
                        |> Ports.webnativeRequest
                    )
           )


gotContextForIngredientsIndex : Ingredients.IndexContext -> Manager
gotContextForIngredientsIndex indexContext model =
    (case model.page of
        Ingredients (Ingredients.Index _) ->
            Ingredients (Ingredients.Index indexContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


gotContextForNewIngredient : Ingredients.NewContext -> Manager
gotContextForNewIngredient newContext model =
    (case model.page of
        Ingredients (Ingredients.New _) ->
            Ingredients (Ingredients.New newContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


loadedIngredients : { json : String } -> Manager
loadedIngredients { json } model =
    case Decode.decodeString (Decode.listIgnore Ingredient.ingredient) json of
        Ok ingredients ->
            model.userData
                |> (\u -> { u | ingredients = Success ingredients })
                |> (\u -> { model | userData = u })
                |> Return.singleton

        Err err ->
            model.userData
                |> (\u -> { u | ingredients = Failure (Decode.errorToString err) })
                |> (\u -> { model | userData = u })
                |> Return.singleton


remove : { uuid : String } -> Manager
remove args model =
    args
        |> UserData.removeIngredient model.userData
        |> (\u ->
                return
                    { model
                        | page = Ingredients Ingredients.index
                        , userData = u
                    }
                    (u.ingredients
                        |> RemoteData.withDefault []
                        |> Ingredients.Wnfs.save
                        |> Ports.webnativeRequest
                    )
           )
