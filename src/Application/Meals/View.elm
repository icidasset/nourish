module Meals.View exposing (navigation, view)

import Chunky exposing (..)
import Common
import Date
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Events.Extra as E
import Html.Extra as Html
import Ingredient exposing (Ingredient, ingredient)
import Iso8601
import Kit.Components
import List.Extra as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Maybe.Extra as Maybe
import Meal exposing (Meal)
import Meals.Common exposing (..)
import Meals.Page exposing (..)
import Meals.Replacement as Replacement exposing (..)
import MultiSelect
import Nourishment exposing (Nourishment, nourishment)
import Page
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Time
import UI.Kit exposing (multiSelect)
import Url
import UserData


view : Page -> Model -> Html Msg
view page model =
    UI.Kit.layout
        []
        (case page of
            Detail context ->
                detail context model

            Edit context ->
                edit context model

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



-- DETAIL


detail context model =
    case UserData.findMeal context model.userData of
        Just meal ->
            [ UI.Kit.buttonContainer
                [ UI.Kit.buttonLinkWithSize
                    Kit.Components.Normal
                    [ { uuid = context.uuid }
                        |> Meals.Page.edit
                        |> Page.Meals
                        |> Page.toString
                        |> String.append "#"
                        |> A.href
                    ]
                    [ Html.text "Edit" ]
                , UI.Kit.buttonWithSize
                    Kit.Components.Normal
                    [ E.onDoubleClick (RemoveMeal { uuid = context.uuid }) ]
                    [ Html.text "Double click to remove" ]
                ]
            ]

        Nothing ->
            []



-- EDIT


edit : EditContext -> Model -> List (Html Msg)
edit context model =
    let
        meal =
            case context.meal of
                Just i ->
                    Just i

                Nothing ->
                    UserData.findMeal context model.userData
    in
    [ UI.Kit.h1
        []
        [ Html.text "Edit meal" ]

    --
    , scheduledAtField
        { currentTime = model.currentTime
        , onInput = \scheduledAt -> GotContextForMealEdit { context | scheduledAt = Just scheduledAt }
        , value =
            Maybe.orElse
                (Maybe.map .scheduledAt meal)
                context.scheduledAt
        }

    --
    , itemsField
        { msg = \items -> GotContextForMealEdit { context | items = Just items }
        , userData = model.userData
        , value =
            context.items
                |> Maybe.orElse
                    (Maybe.map
                        (.items >> MultiSelect.init)
                        meal
                    )
                |> Maybe.withDefault (MultiSelect.init [])
        }

    --
    , case
        MultiSelect.selectedItems
            { includeCreated = False }
            (model.userData.nourishments
                |> RemoteData.withDefault []
                |> List.sortBy .name
                |> List.map (\n -> { name = n.name, value = n.name })
            )
            (Maybe.withDefault
                (MultiSelect.init <| Maybe.unwrap [] .items meal)
                context.items
            )
      of
        [] ->
            Html.nothing

        selectedNourishments ->
            let
                ingredients =
                    RemoteData.withDefault [] model.userData.ingredients

                nourishments =
                    RemoteData.withDefault [] model.userData.nourishments

                replacements =
                    context.replacements
                        |> Maybe.or
                            (Maybe.map
                                (\{ replacedIngredients } ->
                                    Replacement.fromDictionary
                                        replacedIngredients
                                        ingredients
                                        nourishments
                                )
                                meal
                            )
                        |> Maybe.withDefault
                            []
            in
            replaceIngredientsField
                { availableIngredients = ingredients
                , contextMsgConstructor =
                    \c ->
                        case c of
                            UpdateReplacementConstructor con ->
                                GotContextForMealEdit { context | replacementConstructor = con }

                            UpdateReplacementsAndConstructor rep con ->
                                GotContextForMealEdit { context | replacements = Just rep, replacementConstructor = con }
                , nourishments = nourishments
                , replacements = replacements
                , replacementConstructor = context.replacementConstructor
                , selectedNourishments = selectedNourishments
                }

    --
    , notesField
        { onInput =
            \notes -> GotContextForMealEdit { context | notes = Just notes }
        , value =
            context.notes
                |> Maybe.orElse (Maybe.andThen .notes meal)
                |> Maybe.withDefault ""
        }

    --
    , nameField
        { onInput =
            \name -> GotContextForMealEdit { context | name = Just name }
        , value =
            context.name
                |> Maybe.orElse (Maybe.andThen .name meal)
                |> Maybe.withDefault ""
        }

    --
    , UI.Kit.buttonWithSize
        Kit.Components.Normal
        [ E.onClick (EditMeal context) ]
        [ Icons.done 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Save meal" ]
        ]
    ]



-- INDEX


index : List Meal -> Model -> List (Html Msg)
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
    , renderItems (List.reverse past |> List.take 50)
    ]


indexItem ( _, meal ) =
    -- TODO: Group by date
    chunk
        Html.div
        [ "mt-3", "text-sm" ]
        []
        [ meal.scheduledAt
            |> Date.fromIsoString
            |> Result.map
                (\date ->
                    chunk
                        Html.a
                        []
                        [ A.href ("#/meals/" ++ Url.percentEncode meal.uuid ++ "/") ]
                        [ Html.text (Date.format "EEEE, d MMMM y" date) ]
                )
            |> Result.withDefault Html.nothing

        --
        , meal.items
            |> Common.enumerate
            |> Html.text
            |> List.singleton
            |> chunk Html.div [ "italic", "mt-px", "pt-px", "text-xs" ] []
        ]


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


new : NewContext -> Model -> List (Html Msg)
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
            { includeCreated = False }
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
                , contextMsgConstructor =
                    \c ->
                        case c of
                            UpdateReplacementConstructor con ->
                                GotContextForNewMeal { context | replacementConstructor = con }

                            UpdateReplacementsAndConstructor rep con ->
                                GotContextForNewMeal { context | replacements = rep, replacementConstructor = con }
                , nourishments = RemoteData.withDefault [] model.userData.nourishments
                , replacements = context.replacements
                , replacementConstructor = context.replacementConstructor
                , selectedNourishments = selectedNourishments
                }

    --
    , notesField
        { onInput = \notes -> GotContextForNewMeal { context | notes = Just notes }
        , value = Maybe.withDefault "" context.notes
        }

    --
    , nameField
        { onInput = \name -> GotContextForNewMeal { context | name = Just name }
        , value = Maybe.withDefault "" context.name
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
            [ A.for "meal_items" ]
            [ Html.text "Food & Ingredients" ]
        , UI.Kit.multiSelect
            { addButton = [ UI.Kit.multiSelectAddButton value ]
            , allowCreation = True
            , inputPlaceholder = "Type to find a food or an ingredient"
            , items = items
            , msg = msg
            , uid = "meal_items"
            }
            value
        ]


nameField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "meal_name" ]
            [ Html.text "Name (optional)" ]
        , UI.Kit.textField
            [ A.id "meal_name"
            , E.onInput onInput
            , A.type_ "text"
            , A.value value
            ]
            []
        ]


notesField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "meal_notes" ]
            [ Html.text "Notes (optional)" ]
        , UI.Kit.textArea
            [ A.id "meal_notes"
            , A.rows 3
            , A.value value
            , E.onInput onInput
            ]
            []
        ]


scheduledAtField { currentTime, onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "meal_date" ]
            [ Html.text "Date" ]
        , UI.Kit.textField
            [ A.id "meal_date"
            , E.onInput onInput
            , A.placeholder ""
            , A.required True
            , A.type_ "date"
            , A.value
                (case value of
                    Just v ->
                        v

                    Nothing ->
                        defaultDate { currentTime = currentTime }
                )
            ]
            []
        ]



-- FIELDS  ▒  INGREDIENT REPLACING


type ContextMsgConstructor
    = UpdateReplacementConstructor Constructor
    | UpdateReplacementsAndConstructor (List Replacement) Constructor


type alias ReplaceIngredientFieldArgs =
    { availableIngredients : List Ingredient
    , contextMsgConstructor : ContextMsgConstructor -> Msg
    , nourishments : List Nourishment
    , replacements : List Replacement
    , replacementConstructor : Constructor
    , selectedNourishments : List { name : String, value : String }
    }


replaceIngredientsField : ReplaceIngredientFieldArgs -> Html Msg
replaceIngredientsField ({ replacements, replacementConstructor } as arguments) =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "meal_replacements" ]
            [ Html.text "Replace Ingredients" ]

        -----------------------------------------
        -- Replacements
        -----------------------------------------
        , chunk
            Html.div
            (case replacements of
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
                replacements
            )

        -----------------------------------------
        -- Construct a replacement
        -----------------------------------------
        , case replacementConstructor of
            NothingSelectedYet a ->
                nothingSelectedYet arguments a

            SelectedNourishment a b ->
                selectedNourishment arguments a b

            SelectedIngredient a b c ->
                selectedIngredient arguments a b c
        ]


nothingSelectedYet : ReplaceIngredientFieldArgs -> MultiSelect.State -> Html Msg
nothingSelectedYet { contextMsgConstructor, nourishments, selectedNourishments } state =
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
                    |> UpdateReplacementConstructor
                    |> contextMsgConstructor
        , uid = "meal_replacements"
        }
        state


selectedNourishment : ReplaceIngredientFieldArgs -> Nourishment -> MultiSelect.State -> Html Msg
selectedNourishment { availableIngredients, contextMsgConstructor } nourishment state =
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
                |> UpdateReplacementConstructor
                |> contextMsgConstructor
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
                        |> UpdateReplacementConstructor
                        |> contextMsgConstructor
            , uid = "meal_replacements"
            }
            state
        ]


selectedIngredient : ReplaceIngredientFieldArgs -> Nourishment -> Ingredient -> MultiSelect.State -> Html Msg
selectedIngredient { availableIngredients, contextMsgConstructor, replacements } nourishment ingredient state =
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
                        UpdateReplacementsAndConstructor
                            (replacements ++ [ r ])
                            (NothingSelectedYet <| MultiSelect.init [])
                   )
                |> contextMsgConstructor
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
                |> UpdateReplacementConstructor
                |> contextMsgConstructor
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
                |> UpdateReplacementConstructor
                |> contextMsgConstructor
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
                        |> UpdateReplacementConstructor
                        |> contextMsgConstructor
            , uid = "meal_replacements"
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
