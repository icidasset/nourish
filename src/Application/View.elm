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
        , "font-body"
        , "min-h-screen"
        , "relative"
        , "text-gray-700"

        -- Dark mode
        ------------
        , "dark:bg-gray-900"
        , "dark:text-gray-300"
        ]
        [ A.style "text-rendering" "geometricPrecision" ]
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
        , mainNavigation page
        ]


mainNavigation page =
    chunk
        Html.nav
        [ "bg-gray-100"
        , "flex"
        , "justify-between"
        , "px-10"
        , "py-5"
        , "text-gray-500"
        , "text-opacity-80"

        -- Dark mode
        ------------
        , "dark:bg-gray-900"
        ]
        []
        [ link
            (case page of
                Ingredients _ ->
                    True

                _ ->
                    False
            )
            [ A.href "/ingredients/" ]
            [ Icons.park 20 Inherit ]
        , link
            False
            [ A.href "/store/" ]
            [ Icons.store 20 Inherit ]
        , link
            False
            [ A.href "/recipes/" ]
            [ Icons.local_dining 20 Inherit ]
        , link
            False
            [ A.href "/menu/" ]
            [ Icons.calendar_view_week 20 Inherit ]
        ]


link isActive =
    chunk
        Html.a
        [ "inline-block"
        , "text-opacity-80"
        , "dark:text-opacity-80"

        --
        , if isActive then
            "text-green-500"

          else
            "text-inherit"

        --
        , if isActive then
            "dark:text-green-700"

          else
            "dark:text-inherit"
        ]
