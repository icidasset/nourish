module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import MultiSelect
import Page exposing (Page)
import Url exposing (Url)



-- 🌱


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , url : Url
    }



-- 📣


type Msg
    = Bypassed
      -----------------------------------------
      -- Ingredients
      -----------------------------------------
    | GotNewTags MultiSelect.State
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
