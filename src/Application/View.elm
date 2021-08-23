module View exposing (view)

import Chunky exposing (..)
import Color
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Ingredients.View as Ingredients
import Kit.Components as Fission
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Nourishments.View as Nourishments
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))
import UI.Kit


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
        (if model.preparing then
            [ UI.Kit.layout
                []
                [ Html.text "Loading ..." ]
            ]

         else
            [ case model.page of
                Index ->
                    indexView model

                Ingredients page ->
                    Ingredients.view page model

                Nourishments page ->
                    Nourishments.view page model

            --
            , navigation model.page
            ]
        )


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

            Nourishments nourishmentsPage ->
                Nourishments.navigation nourishmentsPage

        --
        , mainNavigation page
        ]


mainNavigation page =
    chunk
        Html.nav
        [ "bg-gray-100"
        , "flex"
        , "justify-between"
        , "px-8"
        , "py-5"
        , "text-gray-500"
        , "text-opacity-80"

        -- Dark mode
        ------------
        , "dark:bg-gray-900"
        ]
        []
        [ link
            False
            [ A.href "/" ]
            [ Icons.cottage 20 Inherit ]
        , link
            False
            [ A.href "/menu/" ]
            [ Icons.calendar_view_week 20 Inherit ]
        , link
            False
            [ A.href "/foods/" ]
            [ Icons.local_dining 20 Inherit ]
        , link
            False
            [ A.href "/stores/" ]
            [ Icons.store 20 Inherit ]
        , link
            (case page of
                Ingredients _ ->
                    True

                _ ->
                    False
            )
            [ A.href "/ingredients/" ]
            [ Icons.park 20 Inherit ]
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



-- INDEX


indexView model =
    case model.userData.userName of
        Nothing ->
            UI.Kit.layout
                []
                [ Html.text "Not authenticated, if you want to keep your data around, log into your Fission account."
                , chunk
                    Html.div
                    [ "mt-4" ]
                    []
                    [ Fission.signIn
                        [ A.class "bg-green-600 bg-opacity-60 text-white text-opacity-90"
                        , E.onClick SignIn
                        ]
                    ]
                ]

        Just userName ->
            UI.Kit.layout
                []
                [ Html.text "Authenticated as "
                , Html.text userName
                ]
