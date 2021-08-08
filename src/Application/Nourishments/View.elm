module Nourishments.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import List.Ext as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import MultiSelect
import Nourishments.Page exposing (Page(..))
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
            , chunk
                Html.ul
                [ "list-disc"
                , "list-inside"
                , "mb-5"
                ]
                []
                (List.map
                    (\ingredient ->
                        Html.li
                            []
                            [ Html.text ingredient.name
                            ]
                    )
                    nourishment.ingredients
                )

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
            , UI.Kit.button
                [ E.onClick (RemoveNourishment { uuid = context.uuid }) ]
                [ Html.text "Remove" ]
            ]

        Nothing ->
            -- TODO
            []



-- INDEX


index context nourishments _ =
    case nourishments of
        [] ->
            indexHeader :: []

        _ ->
            indexHeader :: nourishmentsList context nourishments


indexHeader =
    UI.Kit.h1
        []
        [ Html.text "Food" ]


nourishmentsList context nourishments =
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
            , items =
                -- TODO
                []
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
    , UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_name" ]
            [ Html.text "Name" ]
        , UI.Kit.textField
            [ A.id "nourishment_name"
            , E.onInput
                (\name ->
                    GotContextForNewNourishment
                        { context | name = name }
                )
            , A.placeholder "Soup"
            , A.required True
            , A.type_ "text"
            , A.value context.name
            ]
            []
        ]

    --
    , UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_description" ]
            [ Html.text "Description" ]
        , UI.Kit.textArea
            [ A.id "nourishment_description"
            , A.rows 3
            , A.value (Maybe.withDefault "" context.description)
            , E.onInput
                (\description ->
                    GotContextForNewNourishment
                        { context | description = Just description }
                )
            ]
            []
        ]

    --
    , UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_ingredients" ]
            [ Html.text "Ingredients" ]
        , UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = False -- TODO: Allow creation as well
            , inputPlaceholder = "Type to find an ingredient"
            , items =
                model.userData.ingredients
                    |> RemoteData.withDefault []
                    |> List.map .name
            , msg =
                \ingredients ->
                    GotContextForNewNourishment
                        { context | ingredients = ingredients }
            , uid = "selectTags"
            }
            context.ingredients
        ]

    --
    , UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_tags" ]
            [ Html.text "Tags" ]
        , UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = True
            , inputPlaceholder = "Type to find or create a tag"
            , items = List.sort [ "Breakfast", "Dinner", "Lunch", "Supper" ]
            , msg =
                \tags ->
                    GotContextForNewNourishment
                        { context | tags = MultiSelect.mapSelected List.sort tags }
            , uid = "selectTags"
            }
            context.tags
        ]

    --
    , UI.Kit.formField
        [ UI.Kit.label
            [ A.for "nourishment_instructions" ]
            [ Html.text "Instructions" ]
        , UI.Kit.textArea
            [ A.id "nourishment_instructions"
            , A.rows 3
            , A.value (Maybe.withDefault "" context.instructions)
            , E.onInput
                (\instructions ->
                    GotContextForNewNourishment
                        { context | instructions = Just instructions }
                )
            ]
            []
        ]

    --
    , UI.Kit.button
        [ E.onClick (AddNourishment context) ]
        [ Icons.add 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Add food" ]
        ]
    ]
