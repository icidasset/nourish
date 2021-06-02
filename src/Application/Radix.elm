module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page
import Page exposing (Page)
import Url exposing (Url)
import UserData exposing (UserData)
import Webnative
import Wnfs



-- 🌱


type alias Flags =
    { authenticatedUsername : Maybe String
    }


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , url : Url
    , userData : UserData
    }


appBase : Wnfs.Base
appBase =
    Wnfs.AppData appPermissions


appPermissions : Webnative.AppPermissions
appPermissions =
    { creator = "icidasset"
    , name = "Nourish"
    }


permissions : Webnative.Permissions
permissions =
    { app = Just appPermissions
    , fs = Nothing
    }



-- 📣


type Msg
    = Bypassed
    | Initialised Flags
    | GotWebnativeResponse Webnative.Response
      -----------------------------------------
      -- Ingredients
      -----------------------------------------
    | AddIngredient Ingredients.Page.NewContext
    | GotContextForIngredientsIndex Ingredients.Page.IndexContext
    | GotContextForNewIngredient Ingredients.Page.NewContext
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
