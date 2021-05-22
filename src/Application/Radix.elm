module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredient exposing (Ingredient)
import Ingredients.Page
import Page exposing (Page)
import Url exposing (Url)



-- 🌱


type alias Model =
    { ingredients : List Ingredient
    , navKey : Nav.Key
    , page : Page
    , url : Url
    }



-- 📣


type Msg
    = Bypassed
      -----------------------------------------
      -- Ingredients
      -----------------------------------------
    | GotContextForIngredientsIndex Ingredients.Page.IndexContext
    | GotContextForNewIngredient Ingredients.Page.NewContext
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
