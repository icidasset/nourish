module Meals.State exposing (..)

import Meals.Page as Meals
import Page exposing (Page(..))
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)


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
