module Nourishments.View exposing (navigation, view)

import Chunky exposing (..)
import Common
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import List.Extra as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Maybe.Extra as Maybe
import MultiSelect
import Nourishments.Page exposing (Page(..))
import Page
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import UI.Kit
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

            Index context ->
                case model.userData.nourishments of
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

                    Success nourishments ->
                        index context nourishments model

            New context ->
                new context model
        )



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index _ ->
            UI.Kit.bottomNavButton
                [ A.href "/foods/new/" ]
                Icons.add
                "Add food"

        _ ->
            UI.Kit.bottomNavButton
                [ A.href "../" ]
                Icons.arrow_back
                "Back to list"



-- DETAIL


detail context model =
    case UserData.findNourishment context model.userData of
        Just nourishment ->
            [ UI.Kit.h1
                []
                [ Html.text nourishment.name ]

            --
            , case nourishment.description of
                Just description ->
                    UI.Kit.paragraph
                        []
                        [ Html.text description ]

                Nothing ->
                    Html.nothing

            --
            , UI.Kit.label
                []
                [ Html.text "Ingredients" ]
            , nourishment.ingredients
                |> List.sortBy .name
                |> List.map
                    (\ingredient ->
                        Html.li
                            []
                            [ Html.text ingredient.name
                            ]
                    )
                |> chunk
                    Html.ul
                    [ "list-disc"
                    , "list-inside"
                    , "mb-5"
                    ]
                    []

            --
            , case nourishment.instructions of
                Just instructions ->
                    Html.div
                        []
                        [ UI.Kit.label
                            []
                            [ Html.text "Instructions" ]
                        , UI.Kit.paragraph
                            []
                            [ Html.text instructions ]
                        ]

                Nothing ->
                    Html.nothing

            --
            , UI.Kit.buttonLink
                [ { uuid = context.uuid }
                    |> Nourishments.Page.edit
                    |> Page.Nourishments
                    |> Page.toString
                    |> A.href
                ]
                [ Html.text "Edit" ]

            --
            , UI.Kit.button
                [ E.onDoubleClick (RemoveNourishment { uuid = context.uuid })
                , A.class "mt-3"
                ]
                [ Html.text "Double click to remove" ]
            ]

        Nothing ->
            -- TODO
            []



-- EDIT


edit context model =
    let
        nourishment =
            case context.nourishment of
                Just i ->
                    Just i

                Nothing ->
                    UserData.findNourishment context model.userData
    in
    [ UI.Kit.h1
        []
        [ Html.text "Edit food" ]

    --
    , nameField
        { onInput =
            \name -> GotContextForNourishmentEdit { context | name = Just name }
        , value =
            context.name
                |> Maybe.orElse (Maybe.map .name nourishment)
                |> Maybe.withDefault ""
        }

    --
    , descriptionField
        { onInput =
            \description -> GotContextForNourishmentEdit { context | description = Just description }
        , value =
            context.description
                |> Maybe.orElse (Maybe.andThen .description nourishment)
                |> Maybe.withDefault ""
        }

    --
    , ingredientsField
        { msg =
            \ingredients ->
                GotContextForNourishmentEdit
                    { context | ingredients = Just ingredients }
        , userData =
            model.userData
        , value =
            context.ingredients
                |> Maybe.orElse
                    (Maybe.map
                        (.ingredients >> List.map .name >> MultiSelect.init)
                        nourishment
                    )
                |> Maybe.withDefault (MultiSelect.init [])
        }

    --
    , tagsField
        { available =
            model.tags.nourishments
        , msg =
            \tags ->
                GotContextForNourishmentEdit
                    { context | tags = Just (MultiSelect.mapSelected List.sort tags) }
        , value =
            context.tags
                |> Maybe.orElse (Maybe.map (.tags >> MultiSelect.init) nourishment)
                |> Maybe.withDefault (MultiSelect.init [])
        }

    --
    , instructionsField
        { onInput =
            \instructions ->
                GotContextForNourishmentEdit
                    { context | instructions = Just instructions }
        , value =
            context.instructions
                |> Maybe.orElse (Maybe.andThen .instructions nourishment)
                |> Maybe.withDefault ""
        }

    --
    , UI.Kit.button
        [ E.onClick (EditNourishment context) ]
        [ Icons.done 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Save food" ]
        ]
    ]



-- INDEX


index context nourishments model =
    case nourishments of
        [] ->
            indexHeader :: []

        _ ->
            indexHeader :: nourishmentsList context nourishments model


indexHeader =
    UI.Kit.h1
        []
        [ Html.text "Food" ]


nourishmentsList context nourishments model =
    let
        tags =
            context.filter
                |> MultiSelect.selected
                |> List.map String.toLower
    in
    [ chunk
        Html.div
        [ "mt-6"
        ]
        []
        [ UI.Kit.multiSelect
            { addButton =
                [ Icons.filter_alt 18 Inherit ]
            , allowCreation = False
            , inputPlaceholder = "Search tags"
            , items = MultiSelect.initItemList model.tags.nourishments
            , msg =
                \filter ->
                    GotContextForNourishmentsIndex
                        { context | filter = MultiSelect.mapSelected List.sort filter }
            , uid = "selectTags"
            }
            context.filter
        ]

    --
    , nourishments
        |> List.filter
            (\ingredient ->
                List.isSubsequenceOf
                    tags
                    (List.map String.toLower ingredient.tags)
            )
        |> List.map
            (\ingredient ->
                chunk
                    Html.div
                    [ "mb-2" ]
                    []
                    [ chunk
                        Html.a
                        []
                        [ A.href (Url.percentEncode ingredient.uuid ++ "/") ]
                        [ Html.text
                            ingredient.name
                        ]
                    ]
            )
        |> chunk
            Html.div
            [ "mt-8" ]
            []
    ]



-- NEW


new context model =
    [ UI.Kit.h1
        []
        [ Html.text "Add a new food" ]

    --
    , nameField
        { onInput =
            \name -> GotContextForNewNourishment { context | name = name }
        , value =
            context.name
        }

    --
    , descriptionField
        { onInput =
            \description -> GotContextForNewNourishment { context | description = Just description }
        , value =
            Maybe.withDefault "" context.description
        }

    --
    , ingredientsField
        { msg =
            \ingredients ->
                GotContextForNewNourishment
                    { context | ingredients = ingredients }
        , userData =
            model.userData
        , value =
            context.ingredients
        }

    --
    , tagsField
        { available =
            model.tags.nourishments
        , msg =
            \tags ->
                GotContextForNewNourishment
                    { context | tags = MultiSelect.mapSelected List.sort tags }
        , value =
            context.tags
        }

    --
    , instructionsField
        { onInput =
            \instructions ->
                GotContextForNewNourishment
                    { context | instructions = Just instructions }
        , value =
            Maybe.withDefault "" context.instructions
        }

    --
    , UI.Kit.button
        [ E.onClick (AddNourishment context) ]
        [ Icons.add 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Add food" ]
        ]
    ]



-- FIELDS


descriptionField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_description" ]
            [ Html.text "Description" ]
        , UI.Kit.textArea
            [ A.id "nourishment_description"
            , A.rows 3
            , A.value value
            , E.onInput onInput
            ]
            []
        ]


ingredientsField { msg, userData, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_ingredients" ]
            [ Html.text "Ingredients" ]
        , UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = True
            , inputPlaceholder = "Type to find, or create, an ingredient"
            , items =
                userData.ingredients
                    |> RemoteData.withDefault []
                    |> List.sortBy .name
                    |> List.map Common.emojiMultiSelectItem
            , msg = msg
            , uid = "selectIngredients"
            }
            value
        ]


instructionsField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_instructions" ]
            [ Html.text "Instructions" ]
        , UI.Kit.textArea
            [ A.id "nourishment_instructions"
            , A.rows 3
            , A.value value
            , E.onInput onInput
            ]
            []
        ]


nameField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_name" ]
            [ Html.text "Name" ]
        , UI.Kit.textField
            [ A.id "nourishment_name"
            , E.onInput onInput
            , A.placeholder "Soup"
            , A.required True
            , A.type_ "text"
            , A.value value
            ]
            []
        ]


tagsField { available, msg, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_tags" ]
            [ Html.text "Tags" ]
        , UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = True
            , inputPlaceholder = "Type to find or create a tag"
            , items = MultiSelect.initItemList available
            , msg = msg
            , uid = "selectTags"
            }
            value
        ]
