module Meals.Page exposing (..)

import Ingredient exposing (Ingredient)
import MultiSelect
import Nourishment exposing (Nourishment)
import String exposing (replace)



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
    , replacementConstructor : ReplacementConstructor
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


type alias Replacement =
    { nourishment : Nourishment
    , ingredientToReplace : Ingredient
    , ingredientsToUseInstead : List Ingredient
    }


type ReplacementConstructor
    = NothingSelectedYet MultiSelect.State
    | SelectedNourishment Nourishment MultiSelect.State
    | SelectedIngredient Nourishment Ingredient MultiSelect.State
