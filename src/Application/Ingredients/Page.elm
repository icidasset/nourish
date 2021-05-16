module Ingredients.Page exposing (..)

import MultiSelect



-- 🌳


type Page
    = Index
    | New NewContext



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
