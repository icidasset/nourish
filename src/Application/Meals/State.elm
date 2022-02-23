module Meals.State exposing (..)

import Json.Decode as Decode
import Json.Decode.Ext as Decode
import Meal
import Meals.Common exposing (defaultDate)
import Meals.Page as Meals
import Meals.Replacement as Replacement
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

        scheduledAt =
            Maybe.withDefault
                (defaultDate { currentTime = model.currentTime })
                context.scheduledAt
    in
    model.userData
        |> UserData.addMeal
            { uuid = UUID.toString uuid

            --
            , items = MultiSelect.selected context.items
            , notes = context.notes
            , replacedIngredients = Replacement.toDictionary context.replacements
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


remove : { uuid : String } -> Manager
remove args model =
    model.userData
        |> UserData.removeMeal args
        |> (\u ->
                return
                    { model | userData = u }
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
