module Json.Decode.Ext exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Maybe.Extra as Maybe



-- 🛠


{-| A list decoder that always succeeds, throwing away the failures.
-}
listIgnore : Decoder a -> Decoder (List a)
listIgnore decoder =
    decoder
        |> Decode.maybe
        |> Decode.list
        |> Decode.map Maybe.values
