module Schedule.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Page
import Radix exposing (..)
import Schedule.Page exposing (Page(..))
import UI.Kit


view : Page -> Model -> Html Msg
view page model =
    UI.Kit.layout
        []
        (case page of
            Index ->
                -- case model.userData.nourishments of
                --     NotAsked ->
                --         []
                --
                --     Loading ->
                --         -- TODO
                --         [ Html.text "Loading" ]
                --
                --     Failure error ->
                --         -- TODO
                --         [ Html.text "Failed to load user data."
                --         , Html.br [] []
                --         , Html.text error
                --         ]
                --
                --     Success nourishments ->
                --         index context nourishments model
                --
                index

            New context ->
                new context model
        )



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index ->
            UI.Kit.bottomNavButton
                [ A.href "/menu/add/" ]
                Icons.event
                "Schedule food"

        _ ->
            UI.Kit.bottomNavButton
                [ A.href "../" ]
                Icons.arrow_back
                "Back to overview"



-- INDEX


index =
    [ UI.Kit.h1
        []
        [ Html.text "What's for dinner?" ]
    ]



-- NEW


new context model =
    [ UI.Kit.h1
        []
        [ Html.text "Schedule food" ]

    --
    ]



-- FIELDS
