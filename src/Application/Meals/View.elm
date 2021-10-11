module Meals.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Meals.Page exposing (Page(..))
import Page
import Radix exposing (..)
import RemoteData
import UI.Kit


view : Page -> Model -> Html Msg
view page model =
    UI.Kit.layout
        []
        (case page of
            Index ->
                -- case model.userData.nourishments of
                --     NotAsked ->
                --         []
                --
                --     Loading ->
                --         -- TODO
                --         [ Html.text "Loading" ]
                --
                --     Failure error ->
                --         -- TODO
                --         [ Html.text "Failed to load user data."
                --         , Html.br [] []
                --         , Html.text error
                --         ]
                --
                --     Success nourishments ->
                --         index context nourishments model
                --
                index

            New context ->
                new context model
        )



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index ->
            UI.Kit.bottomNavButton
                [ A.href "/meals/add/" ]
                Icons.event
                "Plan a meal"

        _ ->
            UI.Kit.bottomNavButton
                [ A.href "../" ]
                Icons.arrow_back
                "Back to overview"



-- INDEX


index =
    [ UI.Kit.h1
        []
        [ Html.text "What's for dinner?" ]
    ]



-- NEW


new context model =
    [ UI.Kit.h1
        []
        [ Html.text "Plan a meal" ]

    --
    , itemsField
        { msg = \items -> GotContextForNewMeal { context | items = items }
        , userData = model.userData
        , value = context.items
        }

    --
    , scheduledAtField
        { onInput = \scheduledAt -> GotContextForNewMeal { context | scheduledAt = Just scheduledAt }
        , value = context.scheduledAt
        }
    ]



-- FIELDS


itemsField { msg, userData, value } =
    let
        ingredients =
            userData.ingredients
                |> RemoteData.withDefault []
                |> List.sortBy .name
                |> List.map
                    (\i ->
                        i.emoji
                            |> Maybe.map (\e -> e ++ " ")
                            |> Maybe.withDefault ""
                            |> (\s -> s ++ i.name)
                    )

        foods =
            userData.nourishments
                |> RemoteData.withDefault []
                |> List.map .name
                |> List.sort

        items =
            List.append foods ingredients
    in
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "schedule_items" ]
            [ Html.text "Food & Ingredients" ]
        , UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = True
            , inputPlaceholder = "Type to find a food or an ingredient"
            , items = items
            , msg = msg
            , uid = "schedule_items"
            }
            value
        ]


scheduledAtField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "schedule_date" ]
            [ Html.text "Date" ]
        , UI.Kit.textField
            [ A.id "schedule_date"
            , E.onInput onInput
            , A.placeholder ""
            , A.required True
            , A.type_ "date"
            , A.value (Maybe.withDefault "" value)
            ]
            []
        ]