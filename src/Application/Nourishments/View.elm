module Nourishments.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
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
                [ A.href "/nourishments/new/" ]
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
            -- , UI.Kit.button
            --     [ E.onClick (RemoveNourishment { uuid = context.uuid }) ]
            --     [ Html.text "Remove" ]
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
    -- [ chunk
    --     Html.div
    --     [ "mt-6"
    --     ]
    --     []
    --     [ UI.Kit.multiSelect
    --         { addButton =
    --             [ Icons.filter_alt 18 Inherit ]
    --         , allowCreation = False
    --         , inputPlaceholder = "Search tags"
    --         , items = List.sort [ "Vegetable", "Legume", "Fruit" ]
    --         , msg =
    --             \filter ->
    --                 GotContextForIngredientsIndex
    --                     { context | filter = MultiSelect.mapSelected List.sort filter }
    --         , uid = "selectTags"
    --         }
    --         context.filter
    --     ]
    --
    -- --
    -- , nourishments
    --     |> List.filter
    --         (\ingredient ->
    --             List.isSubsequenceOf
    --                 tags
    --                 (List.map String.toLower ingredient.tags)
    --         )
    --     |> List.map
    --         (\ingredient ->
    --             chunk
    --                 Html.div
    --                 [ "mb-2" ]
    --                 []
    --                 [ chunk
    --                     Html.a
    --                     []
    --                     [ A.href (Url.percentEncode ingredient.uuid ++ "/") ]
    --                     [ chunk
    --                         Html.span
    --                         [ "mr-2" ]
    --                         []
    --                         [ ingredient.emoji
    --                             |> Maybe.map Html.text
    --                             |> Maybe.withDefault defaultEmoji
    --                         ]
    --                     , Html.text
    --                         ingredient.name
    --                     ]
    --                 ]
    --         )
    --     |> chunk
    --         Html.div
    --         [ "mt-8"
    --         ]
    --         []
    -- ]
    []



-- NEW


new context _ =
    [ UI.Kit.h1
        []
        [ Html.text "Add a new food" ]

    --
    , UI.Kit.label
        [ A.for "ingredient_name" ]
        [ Html.text "Name" ]
    , UI.Kit.textField
        [ A.id "ingredient_name"
        , E.onInput
            (\name ->
                GotContextForNewIngredient
                    { context | name = name }
            )
        , A.placeholder "Brocolli"
        , A.required True
        , A.type_ "text"
        , A.value context.name
        ]
        []

    --
    , UI.Kit.label
        [ A.for "ingredient_emoji" ]
        [ Html.text "Emoji" ]
    , chunk
        Html.input
        (List.map
            (\c ->
                case c of
                    "placeholder-opacity-60" ->
                        "placeholder-opacity-30"

                    _ ->
                        c
            )
            UI.Kit.textFieldClasses
        )
        -- TODO: https://package.elm-lang.org/packages/BrianHicks/elm-string-graphemes/latest/String-Graphemes#length
        [ A.id "ingredient_emoji"
        , E.onInput
            (\emoji ->
                GotContextForNewIngredient
                    { context | emoji = emoji }
            )
        , A.placeholder "🥦"
        , A.type_ "text"
        , A.value context.emoji
        ]
        []

    --
    , UI.Kit.label
        [ A.for "food_tags" ]
        [ Html.text "Tags" ]
    , chunk
        Html.div
        [ "mb-6" ]
        []
        [ UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = True
            , inputPlaceholder = "Type to find or create a tag"
            , items = List.sort [ "Breakfast", "Dinner", "Lunch", "Supper" ]
            , msg =
                -- \tags ->
                --     GotContextForNewIngredient
                --         { context | tags = MultiSelect.mapSelected List.sort tags }
                always Bypassed
            , uid = "selectTags"
            }
            context.tags
        ]

    --
    , UI.Kit.button
        [ E.onClick (AddIngredient context) ]
        [ Icons.add 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Add food" ]
        ]
    ]
