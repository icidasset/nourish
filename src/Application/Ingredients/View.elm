module Ingredients.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Ingredients.Page exposing (Page(..))
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Radix exposing (..)


view : Page -> Model -> Html Msg
view page model =
    Html.text ""


navigation : Page -> Html Msg
navigation page =
    case page of
        Index ->
            chunk
                Html.div
                [ "bg-gray-200"
                , "font-semibold"
                , "flex"
                , "items-center"
                , "justify-center"
                , "px-10"
                , "py-5"
                , "text-center"
                , "text-gray-500"
                , "text-sm"
                ]
                []
                [ chunk
                    Html.span
                    [ "inline-flex"
                    , "items-center"
                    ]
                    []
                    [ Icons.add 20 Inherit
                    , Html.span
                        [ A.class "ml-2" ]
                        [ Html.text "Add ingredient" ]
                    ]
                ]
