module Nourishments.Page exposing (..)

import MultiSelect
import Nourishment exposing (Nourishment)



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
    , nourishment : Maybe Nourishment

    --
    , description : Maybe String
    , name : Maybe String
    , ingredients : Maybe MultiSelect.State
    , instructions : Maybe String
    , tags : Maybe MultiSelect.State
    }


edit : { uuid : String } -> Page
edit { uuid } =
    Edit
        { uuid = uuid
        , nourishment = Nothing

        --
        , description = Nothing
        , name = Nothing
        , ingredients = Nothing
        , instructions = Nothing
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
    { description : Maybe String
    , name : String
    , ingredients : MultiSelect.State
    , instructions : Maybe String
    , tags : MultiSelect.State
    }


new : Page
new =
    New
        { description = Nothing
        , name = ""
        , ingredients = MultiSelect.init []
        , instructions = Nothing
        , tags = MultiSelect.init []
        }
