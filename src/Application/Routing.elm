module Routing exposing (..)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page as Ingredients
import Json.Encode as Json
import Meals.Page as Meals
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
    { url | path = Maybe.withDefault "" url.fragment }
        |> Url.parse route
        |> Maybe.withDefault Index


goToPage : Page -> Nav.Key -> Cmd msg
goToPage page navKey =
    page
        |> Page.toString
        |> String.append "#"
        |> Nav.pushUrl navKey



-- 📣


signIn : Radix.Manager
signIn model =
    permissions
        |> Webnative.redirectToLobby CurrentUrl
        |> Ports.webnativeRequest
        |> return model


signOut : Radix.Manager
signOut model =
    Webnative.signOut
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
        -- Meals
        -----------------------------------------
        , map (Meals Meals.index) (s "meals")
        , map (Meals Meals.new) (s "meals" </> s "add")
        , map
            (\uuid -> Meals <| Meals.detail { uuid = uuid })
            (s "meals" </> string)

        -----------------------------------------
        -- Nourishments
        -----------------------------------------
        , map (Nourishments Nourishments.index) (s "foods")
        , map (Nourishments Nourishments.new) (s "foods" </> s "new")
        , map
            (\uuid -> Nourishments <| Nourishments.detail { uuid = uuid })
            (s "foods" </> string)
        , map
            (\uuid -> Nourishments <| Nourishments.edit { uuid = uuid })
            (s "foods" </> string </> s "edit")
        ]
