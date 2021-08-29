module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page
import Nourishments.Page
import Page exposing (Page)
import UUID
import Url exposing (Url)
import UserData exposing (UserData)
import Webnative
import Wnfs



-- 🌱


type alias Init =
    { seeds : List Int
    }


type alias Flags =
    { authenticatedUsername : Maybe String
    }


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , preparing : Bool
    , seeds : UUID.Seeds
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
    | EditIngredient Ingredients.Page.EditContext
    | GotContextForIngredientEdit Ingredients.Page.EditContext
    | GotContextForIngredientsIndex Ingredients.Page.IndexContext
    | GotContextForNewIngredient Ingredients.Page.NewContext
    | RemoveIngredient { uuid : String }
      -----------------------------------------
      -- Nourishments
      -----------------------------------------
    | AddNourishment Nourishments.Page.NewContext
    | GotContextForNourishmentsIndex Nourishments.Page.IndexContext
    | GotContextForNewNourishment Nourishments.Page.NewContext
    | RemoveNourishment { uuid : String }
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | SignIn
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
