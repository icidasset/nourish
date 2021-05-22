module Ingredients.Page exposing (..)

import MultiSelect



-- 🌳


type Page
    = Index IndexContext
    | New NewContext



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
