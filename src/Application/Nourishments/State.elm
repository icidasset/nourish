module Nourishments.State exposing (..)

import Ingredients.State as Ingredients
import Json.Decode as Decode
import Json.Decode.Ext as Decode
import List.Extra as List
import Maybe.Extra as Maybe
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

        ingredients =
            MultiSelect.selected context.ingredients
    in
    model.userData
        |> UserData.addNourishment
            { uuid = UUID.toString uuid

            --
            , description = context.description
            , ingredients =
                List.map
                    (\name ->
                        { name = name
                        , description = ""
                        }
                    )
                    ingredients
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
        |> Return.andThen (Ingredients.ensureExistence ingredients)
        |> Return.andThen populateTags
        |> Return.command
            (Routing.goToPage
                (Page.Nourishments Nourishments.index)
                model.navKey
            )


edit : Nourishments.EditContext -> Manager
edit ({ uuid } as context) model =
    case UserData.findNourishment { uuid = uuid } model.userData of
        Just nourishment ->
            let
                ingredients =
                    Maybe.map MultiSelect.selected context.ingredients
            in
            model.userData
                |> UserData.replaceNourishment
                    { unit =
                        { nourishment
                            | name = Maybe.withDefault nourishment.name context.name
                            , description = Maybe.or context.description nourishment.description
                            , instructions = Maybe.or context.instructions nourishment.instructions
                            , tags = Maybe.withDefault nourishment.tags (Maybe.map MultiSelect.selected context.tags)

                            --
                            , ingredients =
                                ingredients
                                    |> Maybe.map
                                        (List.map
                                            (\name ->
                                                { name = name
                                                , description = ""
                                                }
                                            )
                                        )
                                    |> Maybe.withDefault nourishment.ingredients
                        }
                    , uuid = uuid
                    }
                |> (\u ->
                        return
                            { model | userData = u }
                            (u.nourishments
                                |> RemoteData.withDefault []
                                |> Nourishments.Wnfs.save
                                |> Ports.webnativeRequest
                            )
                   )
                |> (case ingredients of
                        Just i ->
                            Return.andThen (Ingredients.ensureExistence i)

                        Nothing ->
                            identity
                   )
                |> Return.andThen populateTags
                |> Return.command
                    (Routing.goToPage
                        (Page.Nourishments Nourishments.index)
                        model.navKey
                    )

        Nothing ->
            Return.singleton model


gotContextForNourishmentEdit : Nourishments.EditContext -> Manager
gotContextForNourishmentEdit editContext model =
    (case model.page of
        Nourishments (Nourishments.Edit _) ->
            Nourishments (Nourishments.Edit editContext)

        p ->
            p
    )
        |> (\page -> { model | page = page })
        |> Return.singleton


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
                |> populateTags

        Err err ->
            model.userData
                |> (\u -> { u | nourishments = Failure (Decode.errorToString err) })
                |> (\u -> { model | userData = u })
                |> Return.singleton


populateTags : Manager
populateTags model =
    case model.userData.nourishments of
        Success nourishments ->
            nourishments
                |> List.map .tags
                |> List.concat
                |> List.unique
                |> List.sort
                |> (\tags ->
                        model.tags
                            |> (\t -> { t | nourishments = tags })
                            |> (\t -> { model | tags = t })
                   )
                |> Return.singleton

        _ ->
            Return.singleton model


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
