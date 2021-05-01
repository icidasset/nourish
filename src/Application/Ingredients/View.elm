module Ingredients.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Ingredients.Page exposing (Page(..))
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Radix exposing (..)
import UI.Kit


view : Page -> Model -> Html Msg
view page model =
    case page of
        Index ->
            index model

        New ->
            new model



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index ->
            UI.Kit.bottomNavButton
                [ A.href "/ingredients/new/" ]
                Icons.add
                "Add ingredient"

        New ->
            UI.Kit.bottomNavButton
                [ A.href "../" ]
                Icons.arrow_back
                "Back to list"



-- INDEX


index _ =
    Html.text ""



-- NEW


new _ =
    chunk
        Html.div
        [ "p-5" ]
        []
        [ UI.Kit.h1
            []
            [ Html.text "Add a new ingredient" ]

        --
        , UI.Kit.label
            []
            [ Html.text "Name" ]
        , UI.Kit.textField
            [ A.type_ "text"
            , A.value "Brocolli"
            ]
            []

        --
        , UI.Kit.button
            []
            [ Icons.add 20 Inherit
            , Html.span
                [ A.class "ml-2" ]
                [ Html.text "Add ingredient" ]
            ]
        ]
