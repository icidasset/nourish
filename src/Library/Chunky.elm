module Chunky exposing (..)

import Html exposing (Html)
import Html.Attributes as A


chunk : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> List String -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
chunk node classes a b =
    node
        (A.class (String.join " " classes) :: a)
        b
