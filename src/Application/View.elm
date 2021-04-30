module View exposing (view)

import Chunky exposing (..)
import Color
import Html exposing (Html)
import Html.Attributes as A
import Ingredients.View as Ingredients
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    chunk
        Html.main_
        [ "bg-gray-100"
        , "min-h-screen"
        , "relative"
        , "text-gray-900"
        ]
        []
        [ case model.page of
            Index ->
                -- TODO
                Html.text ""

            Ingredients page ->
                Ingredients.view page model

        --
        , navigation model.page
        ]


navigation page =
    chunk
        Html.section
        [ "bottom-0"
        , "fixed"
        , "left-0"
        , "right-0"
        ]
        []
        [ case page of
            Index ->
                Html.text ""

            Ingredients ingredientsPage ->
                Ingredients.navigation ingredientsPage

        --
        , mainNavigation
        ]


mainNavigation =
    chunk
        Html.nav
        [ "bg-gray-400"
        , "flex"
        , "justify-between"
        , "px-10"
        , "py-5"
        , "text-gray-600"
        ]
        []
        [ link [ A.href "/ingredients" ] [ Icons.park 20 Inherit ]
        , link [ A.href "/store" ] [ Icons.store 20 Inherit ]
        , link [ A.href "/recipes" ] [ Icons.local_dining 20 Inherit ]
        , link [ A.href "/menu" ] [ Icons.calendar_view_week 20 Inherit ]
        ]


link =
    chunk
        Html.a
        [ "inline-block", "opacity-80" ]
