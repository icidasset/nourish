module Meals.View exposing (navigation, view)

import Chunky exposing (..)
import Common
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import Iso8601
import Kit.Components
import List.Extra as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Meals.Page exposing (..)
import MultiSelect
import Nourishment exposing (nourishment)
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
                , context = context
                , nourishments = RemoteData.withDefault [] model.userData.nourishments
                , selectedNourishments = selectedNourishments
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



-- FIELDS  ▒  INGREDIENT REPLACING


replaceIngredientsField ({ context } as arguments) =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "schedule_replacements" ]
            [ Html.text "Replace Ingredients" ]

        -----------------------------------------
        -- Replacements
        -----------------------------------------
        , Html.text "" -- TODO

        -----------------------------------------
        -- Construct a replacement
        -----------------------------------------
        , case context.replacementConstructor of
            NothingSelectedYet a ->
                nothingSelectedYet arguments a

            SelectedNourishment a b ->
                selectedNourishment arguments a b

            SelectedIngredient a b c ->
                selectedIngredient arguments a b c
        ]


nothingSelectedYet { context, nourishments, selectedNourishments } state =
    UI.Kit.multiSelectForNonIconOnlyButtons
        { addButton =
            [ replacementButton
                Icons.find_replace
                "Select food"
            ]
        , allowCreation = False
        , inputPlaceholder = "Type to select a food"
        , items = selectedNourishments
        , msg =
            \a ->
                a
                    |> MultiSelect.selected
                    |> List.head
                    |> Maybe.andThen
                        (\v ->
                            List.find
                                (.name >> (==) v)
                                nourishments
                        )
                    |> Maybe.map
                        (\n ->
                            SelectedNourishment n (MultiSelect.init [])
                        )
                    |> Maybe.withDefault
                        (NothingSelectedYet a)
                    |> (\c ->
                            GotContextForNewMeal { context | replacementConstructor = c }
                       )
        , uid = "schedule_replacements"
        }
        state


selectedNourishment { availableIngredients, context } nourishment state =
    UI.Kit.multiSelectForNonIconOnlyButtons
        { addButton =
            [ replacementButton
                Icons.find_replace
                "Select ingredient"
            ]
        , allowCreation = False
        , inputPlaceholder = "Type to select an ingredient"
        , items =
            List.map
                (\i -> { name = i.name, value = i.name })
                nourishment.ingredients
        , msg =
            \a ->
                a
                    |> MultiSelect.selected
                    |> List.head
                    |> Maybe.andThen
                        (\v ->
                            List.find
                                (.name >> (==) v)
                                availableIngredients
                        )
                    |> Maybe.map
                        (\i ->
                            SelectedIngredient nourishment i (MultiSelect.init [])
                        )
                    |> Maybe.withDefault
                        (SelectedNourishment nourishment a)
                    |> (\c ->
                            GotContextForNewMeal { context | replacementConstructor = c }
                       )
        , uid = "schedule_replacements"
        }
        state


selectedIngredient { availableIngredients, context } nourishment ingredient state =
    UI.Kit.multiSelectForNonIconOnlyButtons
        { addButton =
            [ replacementButton
                Icons.find_replace
                "Select replacement"
            ]
        , allowCreation = False
        , inputPlaceholder = "Type to select a different ingredient"
        , items =
            List.map
                (\i -> { name = i.name, value = i.name })
                availableIngredients
        , msg =
            \a ->
                a
                    |> MultiSelect.selected
                    |> List.head
                    |> Maybe.andThen
                        (\v ->
                            List.find
                                (.name >> (==) v)
                                availableIngredients
                        )
                    |> Maybe.map
                        (\i ->
                            let
                                r =
                                    { nourishment = nourishment
                                    , ingredientToReplace = ingredient
                                    , ingredientToUseInstead = i
                                    }
                            in
                            GotContextForNewMeal
                                { context
                                    | replacements = context.replacements ++ [ r ]
                                    , replacementConstructor = NothingSelectedYet (MultiSelect.init [])
                                }
                        )
                    |> Maybe.withDefault
                        (a
                            |> SelectedIngredient nourishment ingredient
                            |> (\c -> { context | replacementConstructor = c })
                            |> GotContextForNewMeal
                        )
        , uid = "schedule_replacements"
        }
        state


replacementButton icon text =
    Kit.Components.button
        Kit.Components.ExtraSmall
        [ Common.classes UI.Kit.buttonColorClasses ]
        [ icon 16 Inherit
        , chunk
            Html.span
            [ "ml-1"
            , "transform"
            , "translate-y-[1px]"
            ]
            []
            [ Html.text text ]
        ]
