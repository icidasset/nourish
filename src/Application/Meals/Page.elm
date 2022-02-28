module Meals.Page exposing (..)

import Meal exposing (Meal)
import Meals.Replacement as Replacement exposing (..)
import MultiSelect



-- 🌱


type Page
    = Detail DetailContext
    | Edit EditContext
    | Index
    | New NewContext



-- DETAIL


type alias DetailContext =
    { uuid : String
    }


detail : DetailContext -> Page
detail =
    Detail



-- EDIT


type alias EditContext =
    { uuid : String
    , meal : Maybe Meal

    --
    , items : Maybe MultiSelect.State
    , name : Maybe String
    , notes : Maybe String
    , replacements : Maybe (List Replacement)
    , replacementConstructor : Replacement.Constructor
    , scheduledAt : Maybe String
    }


edit : { uuid : String } -> Page
edit { uuid } =
    Edit
        { uuid = uuid
        , meal = Nothing

        --
        , items = Nothing
        , name = Nothing
        , notes = Nothing
        , replacements = Nothing
        , replacementConstructor = NothingSelectedYet (MultiSelect.init [])
        , scheduledAt = Nothing
        }



-- INDEX


index : Page
index =
    Index



-- NEW


type alias NewContext =
    { items : MultiSelect.State
    , name : Maybe String
    , notes : Maybe String
    , replacements : List Replacement
    , replacementConstructor : Replacement.Constructor
    , scheduledAt : Maybe String
    }


new : Page
new =
    New
        { items = MultiSelect.init []
        , name = Nothing
        , notes = Nothing
        , replacements = []
        , replacementConstructor = NothingSelectedYet (MultiSelect.init [])
        , scheduledAt = Nothing
        }
