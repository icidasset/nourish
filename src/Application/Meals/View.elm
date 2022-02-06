module Meals.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Events.Extra as E
import Html.Extra as Html
import Ingredient exposing (ingredient)
import Iso8601
import Kit.Components
import List.Extra as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Meals.Page exposing (..)
import Meals.Replacement as Replacement exposing (..)
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
            { addButton = [ UI.Kit.multiSelectAddButton value ]
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
        , chunk
            Html.div
            (case context.replacements of
                [] ->
                    []

                _ ->
                    [ "mb-4", "mt-2" ]
            )
            []
            (List.map
                (\r ->
                    chunk
                        Html.div
                        [ "mt-2", "text-sm" ]
                        []
                        [ Html.text "Replacing "
                        , Html.strong
                            []
                            [ Html.text r.ingredientToReplace.name ]
                        , Html.text " with "

                        --
                        , case List.unconsLast r.ingredientsToUseInstead of
                            Just ( last, init ) ->
                                (case init of
                                    [] ->
                                        last.name

                                    _ ->
                                        " & " ++ last.name
                                )
                                    |> String.append
                                        (init
                                            |> List.map .name
                                            |> String.join ", "
                                        )
                                    |> Html.text
                                    |> List.singleton
                                    |> Html.strong []

                            Nothing ->
                                Html.text "..."

                        --
                        , Html.text " in "
                        , Html.strong
                            []
                            [ Html.text r.nourishment.name ]
                        , Html.text "."
                        ]
                )
                context.replacements
            )

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
                Icons.ramen_dining
                "Select food"
            ]
        , allowCreation = False
        , inputPlaceholder = "Type to select a food"
        , items = selectedNourishments
        , msg =
            \newState ->
                newState
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
                        (NothingSelectedYet newState)
                    |> (\c ->
                            GotContextForNewMeal { context | replacementConstructor = c }
                       )
        , uid = "schedule_replacements"
        }
        state


selectedNourishment { availableIngredients, context } nourishment state =
    chunk
        Html.div
        []
        []
        [ chunk
            Html.div
            [ "cursor-pointer"
            , "font-bold"
            , "mb-3"
            , "text-sm"
            ]
            [ []
                |> MultiSelect.init
                |> NothingSelectedYet
                |> (\c -> { context | replacementConstructor = c })
                |> GotContextForNewMeal
                |> E.onClick
            ]
            [ Html.text nourishment.name ]

        --
        , UI.Kit.multiSelectForNonIconOnlyButtons
            { addButton =
                [ replacementButton
                    Icons.kitchen
                    "Select ingredient"
                ]
            , allowCreation = False
            , inputPlaceholder = "Type to select an ingredient"
            , items =
                List.map
                    (\i -> { name = i.name, value = i.name })
                    nourishment.ingredients
            , msg =
                \newState ->
                    newState
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
                            (SelectedNourishment nourishment newState)
                        |> (\c ->
                                GotContextForNewMeal { context | replacementConstructor = c }
                           )
            , uid = "schedule_replacements"
            }
            state
        ]


selectedIngredient { availableIngredients, context } nourishment ingredient state =
    let
        confirm =
            state
                |> MultiSelect.selected
                |> List.foldr
                    (\s ( acc, available ) ->
                        List.foldr
                            (\i ( a, b ) ->
                                if i.name == s then
                                    ( i :: a, b )

                                else
                                    ( a, i :: b )
                            )
                            ( acc, [] )
                            available
                    )
                    ( []
                    , availableIngredients
                    )
                |> Tuple.first
                |> (\i ->
                        let
                            r =
                                { nourishment = nourishment
                                , ingredientToReplace = ingredient
                                , ingredientsToUseInstead = i
                                }
                        in
                        GotContextForNewMeal
                            { context
                                | replacements = context.replacements ++ [ r ]
                                , replacementConstructor = NothingSelectedYet (MultiSelect.init [])
                            }
                   )
    in
    chunk
        Html.div
        []
        []
        [ chunk
            Html.div
            [ "cursor-pointer"
            , "font-bold"
            , "mb-1"
            , "text-sm"
            ]
            [ []
                |> MultiSelect.init
                |> NothingSelectedYet
                |> (\c -> { context | replacementConstructor = c })
                |> GotContextForNewMeal
                |> E.onClick
            ]
            [ Html.text nourishment.name ]

        --
        , chunk
            Html.div
            [ "cursor-pointer"
            , "font-bold"
            , "mb-3"
            , "text-sm"
            ]
            [ []
                |> MultiSelect.init
                |> SelectedNourishment nourishment
                |> (\c -> { context | replacementConstructor = c })
                |> GotContextForNewMeal
                |> E.onClick
            ]
            [ Html.text ingredient.name ]

        --
        , UI.Kit.multiSelectForNonIconOnlyButtons
            { addButton =
                [ replacementButton
                    Icons.kitchen
                    (if MultiSelect.isOpened state then
                        ""

                     else
                        "Select replacements"
                    )

                --
                , case MultiSelect.selected state of
                    [] ->
                        Html.nothing

                    _ ->
                        saveButton
                            Icons.done
                            "Confirm"
                            confirm
                ]
            , allowCreation = False
            , inputPlaceholder = "Type to select different ingredients"
            , items =
                List.map
                    (\i -> { name = i.name, value = i.name })
                    availableIngredients
            , msg =
                \newState ->
                    newState
                        |> SelectedIngredient nourishment ingredient
                        |> (\c -> { context | replacementConstructor = c })
                        |> GotContextForNewMeal
            , uid = "schedule_replacements"
            }
            state
        ]


replacementButton icon text =
    chunk
        Html.span
        [ "flex", "items-center" ]
        []
        [ chunk
            Html.span
            [ "bg-orange-600"
            , "bg-opacity-60"
            , "px-2"
            , "py-2"
            , "rounded-full"
            , "text-white"
            ]
            []
            [ icon 16 Inherit ]

        --
        , case text of
            "" ->
                Html.nothing

            _ ->
                chunk
                    Html.span
                    [ "font-medium"
                    , "inline-block"
                    , "ml-2"
                    , "text-opacity-80"
                    , "text-orange-600"
                    , "text-sm"
                    ]
                    []
                    [ Html.text text ]
        ]


saveButton icon text msg =
    chunk
        Html.span
        [ "flex", "items-center", "ml-2" ]
        [ E.onClickPreventDefaultAndStopPropagation msg ]
        [ chunk
            Html.span
            [ "bg-purple-600"
            , "bg-opacity-60"
            , "px-2"
            , "py-2"
            , "rounded-full"
            , "text-white"
            ]
            []
            [ icon 16 Inherit ]

        --
        , case text of
            "" ->
                Html.nothing

            _ ->
                chunk
                    Html.span
                    [ "font-medium"
                    , "inline-block"
                    , "ml-2"
                    , "text-opacity-80"
                    , "text-purple-600"
                    , "text-sm"
                    ]
                    []
                    [ Html.text text ]
        ]
