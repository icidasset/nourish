module Meals.Replacement exposing (..)

import Dict exposing (Dict)
import Ingredient exposing (Ingredient)
import Meal
import MultiSelect
import Nourishment exposing (Nourishment)



-- 🌳


type alias Replacement =
    { nourishment : Nourishment
    , ingredientToReplace : Ingredient
    , ingredientsToUseInstead : List Ingredient
    }


type Constructor
    = NothingSelectedYet MultiSelect.State
    | SelectedNourishment Nourishment MultiSelect.State
    | SelectedIngredient Nourishment Ingredient MultiSelect.State



-- 🛠


toDictionary : List Replacement -> Dict String (Dict String (List Meal.ReplacedIngredient))
toDictionary =
    List.foldl
        (\replacement ->
            Dict.update
                (String.toUpper replacement.nourishment.name)
                (\maybeDict ->
                    maybeDict
                        |> Maybe.withDefault Dict.empty
                        |> Dict.insert
                            (String.toUpper replacement.ingredientToReplace.name)
                            (List.map ingredientToShorthand replacement.ingredientsToUseInstead)
                        |> Just
                )
        )
        Dict.empty


ingredientToShorthand : Ingredient -> Meal.ReplacedIngredient
ingredientToShorthand ingredient =
    { name = ingredient.name, description = "" }
