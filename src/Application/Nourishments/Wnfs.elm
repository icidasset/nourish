module Nourishments.Wnfs exposing (..)

import Json.Encode as Encode
import Nourishment exposing (Nourishment)
import Radix exposing (..)
import Tag exposing (Tag(..))
import UserData
import Webnative
import Webnative.Path
import Wnfs


save : List Nourishment -> Webnative.Request
save nourishments =
    Wnfs.writeUtf8
        (Wnfs.AppData appPermissions)
        { path = UserData.nourishmentsPath
        , tag = Tag.toString SavedNourishments
        }
        (nourishments
            |> Encode.list Nourishment.encodeNourishment
            |> Encode.encode 0
        )
