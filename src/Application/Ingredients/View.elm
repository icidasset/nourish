module Ingredients.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Ingredients.Page exposing (Page(..))
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import MultiSelect
import Radix exposing (..)
import UI.Kit


view : Page -> Model -> Html Msg
view page =
    case page of
        Index ->
            index

        New context ->
            new context



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index ->
            UI.Kit.bottomNavButton
                [ A.href "/ingredients/new/" ]
                Icons.add
                "Add ingredient"

        New _ ->
            UI.Kit.bottomNavButton
                [ A.href "../" ]
                Icons.arrow_back
                "Back to list"



-- INDEX


index _ =
    UI.Kit.layout
        []
        [ UI.Kit.h1
            []
            [ Html.text "Ingredients" ]
        ]



-- NEW


new context _ =
    UI.Kit.layout
        []
        [ UI.Kit.h1
            []
            [ Html.text "Add a new ingredient" ]

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
            [ A.for "ingredient_tags" ]
            [ Html.text "Tags" ]
        , chunk
            Html.div
            [ "mb-6" ]
            []
            [ UI.Kit.multiSelect
                { inputPlaceholder = "Type to find or create a tag"
                , items = List.sort [ "Vegetable", "Legume", "Fruit" ]
                , msg = \tags -> GotContextForNewIngredient { context | tags = MultiSelect.mapSelected List.sort tags }
                , uid = "uid"
                }
                context.tags
            ]

        --
        , UI.Kit.button
            []
            [ Icons.add 20 Inherit
            , Html.span
                [ A.class "ml-2" ]
                [ Html.text "Add ingredient" ]
            ]
        ]
