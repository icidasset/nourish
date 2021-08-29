module Routing exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page as Ingredients
import Nourishments.Page as Nourishments
import Page exposing (Page(..))
import Ports
import Radix exposing (permissions)
import Return exposing (return)
import Url exposing (Url)
import Url.Parser as Url exposing (..)
import Url.Parser.Query as Query
import Webnative exposing (RedirectTo(..))



-- 🛠


fromUrl : Url -> Page
fromUrl url =
    Maybe.withDefault Index (Url.parse route url)


goToPage : Page -> Nav.Key -> Cmd msg
goToPage page navKey =
    page
        |> Page.toString
        |> Nav.pushUrl navKey



-- 📣


signIn : Radix.Manager
signIn model =
    permissions
        |> Webnative.redirectToLobby CurrentUrl
        |> Ports.webnativeRequest
        |> return model


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
        , map
            (\uuid -> Ingredients <| Ingredients.detail { uuid = uuid })
            (s "ingredients" </> string)
        , map
            (\uuid -> Ingredients <| Ingredients.edit { uuid = uuid })
            (s "ingredients" </> string </> s "edit")

        -----------------------------------------
        -- Nourishments
        -----------------------------------------
        , map (Nourishments Nourishments.index) (s "foods")
        , map (Nourishments Nourishments.new) (s "foods" </> s "new")
        , map
            (\uuid -> Nourishments <| Nourishments.detail { uuid = uuid })
            (s "foods" </> string)
        ]
