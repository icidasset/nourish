module Meals.Page exposing (..)

import Meals.Replacement as Replacement exposing (..)
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
    , replacements : List Replacement
    , replacementConstructor : Replacement.Constructor
    , scheduledAt : Maybe String
    }


new : Page
new =
    New
        { items = MultiSelect.init []
        , replacements = []
        , replacementConstructor = NothingSelectedYet (MultiSelect.init [])
        , scheduledAt = Nothing
        }
