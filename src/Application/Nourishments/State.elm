module Nourishments.State exposing (..)

import Json.Decode as Decode
import Json.Decode.Ext as Decode
import MultiSelect
import Nourishment
import Nourishments.Page as Nourishments
import Nourishments.Wnfs
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import String.Extra as String
import UUID
import UserData


add : Nourishments.NewContext -> Manager
add context model =
    let
        ( uuid, newSeeds ) =
            UUID.step model.seeds
    in
    model.userData
        |> UserData.addNourishment
            { uuid = UUID.toString uuid

            --
            , description = context.description
            , ingredients =
                context.ingredients
                    |> MultiSelect.selected
                    |> List.map
                        (\name ->
                            { name = name
                            , description = ""
                            }
                        )
            , instructions = context.instructions
            , name = String.trim context.name
            , tags = MultiSelect.selected context.tags

            -- TODO
            , cookTime = Nothing
            , image = Nothing
            , prepTime = Nothing
            , yields = Nothing
            }
        |> (\u ->
                return
                    { model
                        | seeds = newSeeds
                        , userData = u
                    }
                    (u.nourishments
                        |> RemoteData.withDefault []
                        |> Nourishments.Wnfs.save
                        |> Ports.webnativeRequest
                    )
           )
        |> Return.command
            (Routing.goToPage
                (Page.Nourishments Nourishments.index)
                model.navKey
            )


gotContextForNourishmentsIndex : Nourishments.IndexContext -> Manager
gotContextForNourishmentsIndex indexContext model =
    (case model.page of
        Nourishments (Nourishments.Index _) ->
            Nourishments (Nourishments.Index indexContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


gotContextForNewNourishment : Nourishments.NewContext -> Manager
gotContextForNewNourishment newContext model =
    (case model.page of
        Nourishments (Nourishments.New _) ->
            Nourishments (Nourishments.New newContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


loaded : { json : String } -> Manager
loaded { json } model =
    case Decode.decodeString (Decode.listIgnore Nourishment.nourishment) json of
        Ok nourishments ->
            model.userData
                |> (\u -> { u | nourishments = Success nourishments })
                |> (\u -> { model | userData = u })
                |> Return.singleton

        Err err ->
            model.userData
                |> (\u -> { u | ingredients = Failure (Decode.errorToString err) })
                |> (\u -> { model | userData = u })
                |> Return.singleton


remove : { uuid : String } -> Manager
remove args model =
    model.userData
        |> UserData.removeNourishment args
        |> (\u ->
                return
                    { model | userData = u }
                    (u.nourishments
                        |> RemoteData.withDefault []
                        |> Nourishments.Wnfs.save
                        |> Ports.webnativeRequest
                    )
           )
        |> Return.command
            (Routing.goToPage
                (Page.Nourishments Nourishments.index)
                model.navKey
            )
