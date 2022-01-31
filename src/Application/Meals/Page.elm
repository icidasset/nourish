module Meals.Page exposing (..)

import MultiSelect
import String exposing (replace)



-- 🌱


type Page
    = Index
    | New NewContext



-- INDEX


index : Page
index =
    Index



-- NEW


type alias NewContext =
    { items : MultiSelect.State
    , replacements : MultiSelect.State
    , scheduledAt : Maybe String
    }


new : Page
new =
    New
        { items = MultiSelect.init []
        , replacements = MultiSelect.init []
        , scheduledAt = Nothing
        }
