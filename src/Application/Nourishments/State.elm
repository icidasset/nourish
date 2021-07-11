module Nourishments.State exposing (..)

import Json.Decode as Decode
import Json.Decode.Ext as Decode
import MultiSelect
import Nourishment
import Nourishments.Page as Nourishments
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import String.Extra as String
import UUID
import UserData


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
