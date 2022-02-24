module Meals.Page exposing (..)

import Meals.Replacement as Replacement exposing (..)
import MultiSelect



-- 🌱


type Page
    = Detail DetailContext
    | Index
    | New NewContext



-- DETAIL


type alias DetailContext =
    { uuid : String
    }


detail : DetailContext -> Page
detail =
    Detail



-- INDEX


index : Page
index =
    Index



-- NEW


type alias NewContext =
    { items : MultiSelect.State
    , notes : Maybe String
    , replacements : List Replacement
    , replacementConstructor : Replacement.Constructor
    , scheduledAt : Maybe String
    }


new : Page
new =
    New
        { items = MultiSelect.init []
        , notes = Nothing
        , replacements = []
        , replacementConstructor = NothingSelectedYet (MultiSelect.init [])
        , scheduledAt = Nothing
        }
