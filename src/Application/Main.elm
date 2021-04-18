module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html
import Ingredients.View as Ingredients
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))
import Return exposing (return)
import Routing
import Url exposing (Url)



-- ⛩


type alias Flags =
    {}


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , view = view
        }



-- 🌱


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    Tuple.pair
        { page = Routing.fromUrl url
        , navKey = navKey
        , url = url
        }
        Cmd.none



-- 📣


update : Msg -> Radix.Manager
update msg =
    case msg of
        Bypassed ->
            Return.singleton

        -----------------------------------------
        -- Routing
        -----------------------------------------
        UrlChanged a ->
            Routing.urlChanged a

        UrlRequested a ->
            Routing.urlRequested a



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Nourish"
    , body =
        [ case model.page of
            Index ->
                -- TODO
                Html.text ""

            Ingredients page ->
                Ingredients.view page model
        ]
    }
