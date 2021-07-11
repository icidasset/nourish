module Page exposing (..)

import Ingredients.Page as Ingredients
import Nourishments.Page as Nourishments



-- 🌱


type Page
    = Index
      --
    | Ingredients Ingredients.Page
    | Nourishments Nourishments.Page
