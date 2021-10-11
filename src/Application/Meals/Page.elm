module Meals.Page exposing (..)

import MultiSelect



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
    , scheduledAt : Maybe String
    }


new : Page
new =
    New
        { items = MultiSelect.init []
        , scheduledAt = Nothing
        }
