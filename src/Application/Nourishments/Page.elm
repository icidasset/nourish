module Nourishments.Page exposing (..)

import MultiSelect
import Nourishment exposing (Nourishment)



-- 🌱


type Page
    = Detail DetailContext
    | Index IndexContext
    | New NewContext



-- DETAIL


type alias DetailContext =
    { uuid : String
    }


detail : DetailContext -> Page
detail =
    Detail



-- INDEX


type alias IndexContext =
    { filter : MultiSelect.State
    }


index : Page
index =
    Index
        { filter = MultiSelect.init [] }



-- NEW


type alias NewContext =
    { description : Maybe String
    , name : String
    , ingredients : MultiSelect.State
    , instructions : Maybe String
    , tags : MultiSelect.State
    }


new : Page
new =
    New
        { description = Nothing
        , name = ""
        , ingredients = MultiSelect.init []
        , instructions = Nothing
        , tags = MultiSelect.init []
        }
