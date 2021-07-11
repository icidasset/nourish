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
    { emoji : String
    , name : String
    , tags : MultiSelect.State
    }


new : Page
new =
    New
        { emoji = ""
        , name = ""
        , tags = MultiSelect.init []
        }
