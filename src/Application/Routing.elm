module Routing exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page as Ingredients
import Page exposing (Page(..))
import Radix
import Return exposing (return)
import Url exposing (Url)
import Url.Parser as Url exposing (..)
import Url.Parser.Query as Query



-- 🛠


fromUrl : Url -> Page
fromUrl url =
    Maybe.withDefault Index (Url.parse route url)



-- 📣


urlChanged : Url -> Radix.Manager
urlChanged url model =
    Return.singleton
        { model
            | page = fromUrl url
            , url = url
        }


urlRequested : Browser.UrlRequest -> Radix.Manager
urlRequested request model =
    case request of
        Browser.Internal url ->
            return model (Nav.pushUrl model.navKey <| Url.toString url)

        Browser.External href ->
            return model (Nav.load href)



-- 🔮


route : Parser (Page -> a) a
route =
    oneOf
        [ map Index top

        -----------------------------------------
        -- Ingredients
        -----------------------------------------
        , map (Ingredients Ingredients.index) (s "ingredients")
        , map (Ingredients Ingredients.new) (s "ingredients" </> s "new")
        ]
