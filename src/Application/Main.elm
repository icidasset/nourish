module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))
import Return exposing (return)
import Routing
import Tailwind as T
import Url exposing (Url)
import View



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
        -- Ingredients
        -----------------------------------------
        GotNewTags state ->
            -- TODO
            \model ->
                (case model.page of
                    Ingredients (Ingredients.Page.New context) ->
                        Ingredients (Ingredients.Page.New { context | tags = state })

                    p ->
                        p
                )
                    |> (\page -> { model | page = page })
                    |> Return.singleton

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
    , body = [ View.view model ]
    }
