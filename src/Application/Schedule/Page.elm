module Schedule.Page exposing (..)

import SingleDatePicker as DatePicker exposing (DatePicker)



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
    { item : String
    , scheduledAt : DatePicker
    }


new : Page
new =
    New
        { item = ""
        , scheduledAt = DatePicker.init
        }
