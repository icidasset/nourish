module Ingredients.State exposing (..)

import Ingredient
import Ingredients.Page as Ingredients
import Ingredients.Wnfs
import Json.Decode as Decode
import Json.Decode.Ext as Decode
import Maybe.Extra as Maybe
import MultiSelect
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import String.Extra as String
import UUID
import UserData


add : Ingredients.NewContext -> Manager
add context model =
    let
        ( uuid, newSeeds ) =
            UUID.step model.seeds
    in
    model.userData
        |> UserData.addIngredient
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
        |> (\u ->
                return
                    { model
                        | seeds = newSeeds
                        , userData = u
                    }
                    (u.ingredients
                        |> RemoteData.withDefault []
                        |> Ingredients.Wnfs.save
                        |> Ports.webnativeRequest
                    )
           )
        |> Return.command
            (Routing.goToPage
                (Page.Ingredients Ingredients.index)
                model.navKey
            )


edit : Ingredients.EditContext -> Manager
edit ({ uuid } as context) model =
    case UserData.findIngredient { uuid = uuid } model.userData of
        Just ingredient ->
            model.userData
                |> UserData.replaceIngredient
                    { unit =
                        { ingredient
                            | name = Maybe.withDefault ingredient.name context.name
                            , emoji = Maybe.or context.emoji ingredient.emoji
                            , tags = Maybe.withDefault ingredient.tags (Maybe.map MultiSelect.selected context.tags)
                        }
                    , uuid = uuid
                    }
                |> (\u ->
                        return
                            { model | userData = u }
                            (u.ingredients
                                |> RemoteData.withDefault []
                                |> Ingredients.Wnfs.save
                                |> Ports.webnativeRequest
                            )
                   )
                |> Return.command
                    (Routing.goToPage
                        (Page.Ingredients Ingredients.index)
                        model.navKey
                    )

        Nothing ->
            Return.singleton model


ensureExistence : List String -> Manager
ensureExistence names model =
    case model.userData.ingredients of
        Success currentIngredients ->
            names
                |> List.foldl
                    (\rawName ( acc, seeds, changed ) ->
                        let
                            name =
                                String.trim rawName
                        in
                        if List.any (.name >> (==) name) acc then
                            ( acc, seeds, changed )

                        else
                            let
                                ( uuid, newSeeds ) =
                                    UUID.step seeds

                                newIngredient =
                                    { uuid = UUID.toString uuid

                                    --
                                    , emoji = Nothing
                                    , minerals = []
                                    , name = name
                                    , seasonality = []
                                    , stores = []
                                    , tags = []
                                    , vitamins = []
                                    }
                            in
                            ( acc ++ [ newIngredient ], newSeeds, True )
                    )
                    ( currentIngredients, model.seeds, False )
                |> (\( newIngredients, newSeeds, changed ) ->
                        if changed then
                            model.userData
                                |> UserData.mapIngredients (\_ -> newIngredients)
                                |> (\u -> { model | seeds = newSeeds, userData = u })
                                |> Return.singleton
                                |> Return.command
                                    (newIngredients
                                        |> Ingredients.Wnfs.save
                                        |> Ports.webnativeRequest
                                    )

                        else
                            Return.singleton model
                   )

        _ ->
            Return.singleton model


gotContextForIngredientEdit : Ingredients.EditContext -> Manager
gotContextForIngredientEdit editContext model =
    (case model.page of
        Ingredients (Ingredients.Edit _) ->
            Ingredients (Ingredients.Edit editContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


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


loaded : { json : String } -> Manager
loaded { json } model =
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
    model.userData
        |> UserData.removeIngredient args
        |> (\u ->
                return
                    { model | userData = u }
                    (u.ingredients
                        |> RemoteData.withDefault []
                        |> Ingredients.Wnfs.save
                        |> Ports.webnativeRequest
                    )
           )
        |> Return.command
            (Routing.goToPage
                (Page.Ingredients Ingredients.index)
                model.navKey
            )
