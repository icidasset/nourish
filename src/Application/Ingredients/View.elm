module Ingredients.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
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
            [ A.type_ "text"
            , A.value "Brocolli"
            , A.id "ingredient_name"
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
                , msg = GotNewTags
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
