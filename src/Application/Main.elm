module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Ingredients.Page
import Ingredients.State as Ingredients
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import Random
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import Tag exposing (Tag(..))
import Url exposing (Url)
import UserData
import View
import Webnative exposing (DecodedResponse(..))
import Webnative.Path as Path
import Wnfs



-- ⛩


main : Program Init Model Msg
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


init : Init -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { seeds } url navKey =
    Return.singleton
        { page = Routing.fromUrl url
        , navKey = navKey
        , seeds =
            case seeds of
                [ a, b, c, d ] ->
                    { seed1 = Random.initialSeed a
                    , seed2 = Random.initialSeed b
                    , seed3 = Random.initialSeed c
                    , seed4 = Random.initialSeed d
                    }

                _ ->
                    { seed1 = Random.initialSeed 0
                    , seed2 = Random.initialSeed 0
                    , seed3 = Random.initialSeed 0
                    , seed4 = Random.initialSeed 0
                    }
        , url = url
        , userData = UserData.empty
        }


initPartTwo : Flags -> Manager
initPartTwo flags model =
    model.userData
        |> (\u -> { u | userName = flags.authenticatedUsername })
        |> (\u -> { model | userData = u })
        |> Return.singleton
        |> Return.command
            ({ path = Path.file [ "Ingredients.json" ]
             , tag = Tag.toString LoadedIngredients
             }
                |> Wnfs.readUtf8 appBase
                |> Ports.webnativeRequest
            )



-- 📣


update : Msg -> Radix.Manager
update msg =
    case msg of
        Bypassed ->
            Return.singleton

        Initialised a ->
            initPartTwo a

        GotWebnativeResponse a ->
            gotWebnativeResponse a

        -----------------------------------------
        -- Ingredients
        -----------------------------------------
        AddIngredient a ->
            Ingredients.add a

        GotContextForIngredientsIndex a ->
            Ingredients.gotContextForIngredientsIndex a

        GotContextForNewIngredient a ->
            Ingredients.gotContextForNewIngredient a

        -----------------------------------------
        -- Routing
        -----------------------------------------
        UrlChanged a ->
            Routing.urlChanged a

        UrlRequested a ->
            Routing.urlRequested a


gotWebnativeResponse : Webnative.Response -> Manager
gotWebnativeResponse response model =
    case Webnative.decodeResponse Tag.fromString response of
        Wnfs LoadedIngredients (Wnfs.Utf8Content json) ->
            Ingredients.loadedIngredients { json = json } model

        Wnfs SavedIngredients _ ->
            publish model

        WnfsError (Wnfs.JavascriptError "Path does not exist") ->
            Ingredients.loadedIngredients { json = "[]" } model

        _ ->
            -- TODO
            Return.singleton model


publish : Manager
publish model =
    { tag = Tag.toString Untagged }
        |> Wnfs.publish
        |> Ports.webnativeRequest
        |> return model



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.initialised Initialised
        , Ports.webnativeResponse GotWebnativeResponse
        ]



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Nourish"
    , body = [ View.view model ]
    }
