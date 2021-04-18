module Page exposing (..)

import Ingredients.Page as Ingredients



-- 🌳


type Page
    = Index
      --
    | Ingredients Ingredients.Page
