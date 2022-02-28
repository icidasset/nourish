module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page
import Meals.Page
import Nourishments.Page
import Page exposing (Page)
import Time
import UUID
import Url exposing (Url)
import UserData exposing (UserData)
import Webnative
import Wnfs



-- 🌱


type alias CollectedTags =
    { ingredients : List String
    , nourishments : List String
    }


type alias Init =
    { currentTime : Int
    , seeds : List Int
    }


type alias Flags =
    { authenticatedUsername : Maybe String
    }


type alias Model =
    { currentTime : Time.Posix
    , navKey : Nav.Key
    , page : Page
    , preparing : Bool
    , seeds : UUID.Seeds
    , tags : CollectedTags
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
      -- Meals
      -----------------------------------------
    | AddMeal Meals.Page.NewContext
    | EditMeal Meals.Page.EditContext
    | GotContextForMealEdit Meals.Page.EditContext
    | GotContextForNewMeal Meals.Page.NewContext
    | RemoveMeal { uuid : String }
      -----------------------------------------
      -- Nourishments
      -----------------------------------------
    | AddNourishment Nourishments.Page.NewContext
    | EditNourishment Nourishments.Page.EditContext
    | GotContextForNourishmentEdit Nourishments.Page.EditContext
    | GotContextForNourishmentsIndex Nourishments.Page.IndexContext
    | GotContextForNewNourishment Nourishments.Page.NewContext
    | RemoveNourishment { uuid : String }
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | SignIn
    | SignOut
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
