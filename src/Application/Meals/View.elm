module Meals.View exposing (navigation, view)

import Chunky exposing (..)
import Common
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import Iso8601
import Kit.Components
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Meals.Page exposing (Page(..))
import MultiSelect
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Time
import UI.Kit exposing (multiSelect)


view : Page -> Model -> Html Msg
view page model =
    UI.Kit.layout
        []
        (case page of
            Index ->
                case model.userData.meals of
                    NotAsked ->
                        []

                    Loading ->
                        -- TODO
                        [ Html.text "Loading" ]

                    Failure error ->
                        -- TODO
                        [ Html.text "Failed to load user data."
                        , Html.br [] []
                        , Html.text error
                        ]

                    Success meals ->
                        index meals model

            New context ->
                new context model
        )



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index ->
            UI.Kit.bottomNavButton
                [ A.href "#/meals/add/" ]
                Icons.event
                "Plan a meal"

        _ ->
            UI.Kit.bottomNavButton
                [ A.href "#/meals/" ]
                Icons.arrow_back
                "Back to overview"



-- INDEX


index meals model =
    let
        now =
            Time.posixToMillis model.currentTime

        ( future, past ) =
            meals
                |> List.filterMap
                    (\meal ->
                        case Iso8601.toTime meal.scheduledAt of
                            Ok scheduledAt ->
                                Just ( Time.posixToMillis scheduledAt, meal )

                            Err _ ->
                                Nothing
                    )
                |> List.sortBy Tuple.first
                |> List.partition (\( s, _ ) -> s >= now)

        ( nextWeek, afterNextWeek ) =
            List.partition
                (\( s, _ ) -> s <= now + 604800 * 1000)
                future

        renderItems items =
            case items of
                [] ->
                    nothingPlanned

                _ ->
                    items
                        |> List.map indexItem
                        |> chunk Html.div [ "mb-7" ] []
    in
    [ UI.Kit.h1
        []
        [ Html.text "What's for dinner?" ]

    --
    , UI.Kit.h2 [] [ Html.text "This week" ]
    , renderItems nextWeek

    --
    , UI.Kit.h2 [] [ Html.text "Next week" ]
    , renderItems afterNextWeek

    --
    , UI.Kit.h2 [] [ Html.text "Past" ]
    , renderItems past
    ]


indexItem ( _, meal ) =
    case meal.items of
        item :: _ ->
            chunk
                Html.div
                []
                []
                [ Html.text item ]

        _ ->
            Html.text ""


nothingPlanned =
    chunk
        Html.div
        [ "font-medium"
        , "italic"
        , "mb-7"
        , "opacity-80"
        , "text-sm"
        ]
        []
        [ Html.text "Nothing here yet." ]



-- NEW


new context model =
    [ UI.Kit.h1
        []
        [ Html.text "Plan a meal" ]

    --
    , scheduledAtField
        { currentTime = model.currentTime
        , onInput = \scheduledAt -> GotContextForNewMeal { context | scheduledAt = Just scheduledAt }
        , value = context.scheduledAt
        }

    --
    , itemsField
        { msg = \items -> GotContextForNewMeal { context | items = items }
        , userData = model.userData
        , value = context.items
        }

    --
    , case
        MultiSelect.selectedItems
            (model.userData.nourishments
                |> RemoteData.withDefault []
                |> List.sortBy .name
                |> List.map (\n -> { name = n.name, value = n.name })
            )
            context.items
      of
        [] ->
            Html.nothing

        selectedNourishments ->
            replaceIngredientsField
                { availableIngredients = RemoteData.withDefault [] model.userData.ingredients
                , nourishments = RemoteData.withDefault [] model.userData.nourishments
                , msg = \r -> GotContextForNewMeal { context | replacements = r }
                , selectedNourishments = selectedNourishments
                , value = context.replacements
                }

    --
    , UI.Kit.buttonWithSize
        Kit.Components.Normal
        [ E.onClick (AddMeal context) ]
        [ Icons.add 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Plan" ]
        ]
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
                            |> (\n -> { name = n, value = i.name })
                    )

        foods =
            userData.nourishments
                |> RemoteData.withDefault []
                |> List.sortBy .name
                |> List.map (\n -> { name = n.name, value = n.name })

        items =
            List.append foods ingredients
    in
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "schedule_items" ]
            [ Html.text "Food & Ingredients" ]
        , UI.Kit.multiSelect
            { addButton = [ UI.Kit.multiSelectAddButton ]
            , allowCreation = True
            , inputPlaceholder = "Type to find a food or an ingredient"
            , items = items
            , msg = msg
            , uid = "schedule_items"
            }
            value
        ]


replaceIngredientsField { availableIngredients, msg, nourishments, selectedNourishments, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "schedule_replacements" ]
            [ Html.text "Replace Ingredients" ]
        , UI.Kit.multiSelectForNonIconOnlyButtons
            { addButton =
                [ Kit.Components.button
                    Kit.Components.ExtraSmall
                    [ Common.classes UI.Kit.buttonColorClasses ]
                    [ Icons.find_replace 16 Inherit
                    , chunk
                        Html.span
                        [ "ml-1"
                        , "transform"
                        , "translate-y-[1px]"
                        ]
                        []
                        [ Html.text "Select food" ]
                    ]
                ]
            , allowCreation = False
            , inputPlaceholder = "Type to select a food"
            , items = selectedNourishments
            , msg = msg
            , uid = "schedule_replacements"
            }
            value
        ]


scheduledAtField { currentTime, onInput, value } =
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
            , A.value
                (case value of
                    Just v ->
                        v

                    Nothing ->
                        currentTime
                            |> Iso8601.fromTime
                            |> String.split "T"
                            |> List.head
                            |> Maybe.withDefault ""
                )
            ]
            []
        ]
