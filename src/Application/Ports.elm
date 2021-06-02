port module Ports exposing (..)

import Radix exposing (Flags)
import Webnative



-- 📣


port webnativeRequest : Webnative.Request -> Cmd msg



-- 📰


port initialised : (Flags -> msg) -> Sub msg


port webnativeResponse : (Webnative.Response -> msg) -> Sub msg
