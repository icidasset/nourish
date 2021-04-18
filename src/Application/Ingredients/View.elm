module Ingredients.View exposing (view)

import Html exposing (Html)
import Ingredients.Page exposing (Page(..))
import Radix exposing (..)


view : Page -> Model -> Html Msg
view page model =
    Html.text ""
