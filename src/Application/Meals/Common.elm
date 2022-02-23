module Meals.Common exposing (..)

import Iso8601
import Time


defaultDate : { currentTime : Time.Posix } -> String
defaultDate { currentTime } =
    let
        isoTime =
            Iso8601.fromTime currentTime
    in
    isoTime
        |> String.split "T"
        |> List.head
        |> Maybe.withDefault isoTime
