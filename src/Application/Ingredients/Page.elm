module Ingredients.Page exposing (..)

import Ingredient exposing (Ingredient)
import MultiSelect



-- 🌱


type Page
    = Detail DetailContext
    | Edit EditContext
    | Index IndexContext
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
    , ingredient : Maybe Ingredient

    --
    , emoji : Maybe String
    , name : Maybe String
    , tags : Maybe MultiSelect.State
    }


edit : { uuid : String } -> Page
edit { uuid } =
    Edit
        { uuid = uuid
        , ingredient = Nothing

        --
        , emoji = Nothing
        , name = Nothing
        , tags = Nothing
        }



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
