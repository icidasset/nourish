module Ingredients.Page exposing (..)

import MultiSelect



-- 🌳


type Page
    = Index
    | New NewContext



-- NEW


type alias NewContext =
    { tags : MultiSelect.State
    }


new : Page
new =
    New
        { tags = MultiSelect.init [ "Vegetable" ]
        }
