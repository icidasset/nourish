module Meals.State exposing (..)

import Json.Decode as Decode
import Json.Decode.Ext as Decode
import Meal
import Meals.Page as Meals
import Meals.Wnfs
import MultiSelect
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import UUID
import UserData


add : Meals.NewContext -> Manager
add context model =
    let
        ( uuid, newSeeds ) =
            UUID.step model.seeds
    in
    case context.scheduledAt of
        Just scheduledAt ->
            model.userData
                |> UserData.addMeal
                    { uuid = UUID.toString uuid

                    --
                    , items = MultiSelect.selected context.items
                    , scheduledAt = scheduledAt
                    }
                |> (\u ->
                        return
                            { model
                                | seeds = newSeeds
                                , userData = u
                            }
                            (u.meals
                                |> RemoteData.withDefault []
                                |> Meals.Wnfs.save
                                |> Ports.webnativeRequest
                            )
                   )
                |> Return.command
                    (Routing.goToPage
                        (Page.Meals Meals.index)
                        model.navKey
                    )

        Nothing ->
            Return.singleton model


gotContextForNewMeal : Meals.NewContext -> Manager
gotContextForNewMeal newContext model =
    (case model.page of
        Meals (Meals.New _) ->
            Meals (Meals.New newContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


loaded : { json : String } -> Manager
loaded { json } model =
    case Decode.decodeString (Decode.listIgnore Meal.meal) json of
        Ok meals ->
            model.userData
                |> (\u -> { u | meals = Success meals })
                |> (\u -> { model | userData = u })
                |> Return.singleton

        Err err ->
            model.userData
                |> (\u -> { u | meals = Failure (Decode.errorToString err) })
                |> (\u -> { model | userData = u })
                |> Return.singleton
