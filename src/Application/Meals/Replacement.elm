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


fromDictionary : Dict String (Dict String (List Meal.ReplacedIngredient)) -> List Ingredient -> List Nourishment -> List Replacement
fromDictionary dict ingredients nourishments =
    let
        ingDict =
            ingredients
                |> List.map (\n -> ( String.toUpper n.name, n ))
                |> Dict.fromList

        nouDict =
            nourishments
                |> List.map (\n -> ( String.toUpper n.name, n ))
                |> Dict.fromList
    in
    List.foldr
        (\( nouKey, nestedDict ) acc ->
            nouDict
                |> Dict.get (String.toUpper nouKey)
                |> Maybe.map
                    (\nourishment ->
                        List.foldr
                            (\( ingKey, replacements ) nestedAcc ->
                                ingDict
                                    |> Dict.get (String.toUpper ingKey)
                                    |> Maybe.map
                                        (\ingredient ->
                                            { nourishment = nourishment
                                            , ingredientToReplace = ingredient
                                            , ingredientsToUseInstead =
                                                List.filterMap
                                                    (\{ name } -> Dict.get (String.toUpper name) ingDict)
                                                    replacements
                                            }
                                        )
                                    |> Maybe.map (\a -> a :: nestedAcc)
                                    |> Maybe.withDefault nestedAcc
                            )
                            acc
                            (Dict.toList nestedDict)
                    )
                |> Maybe.withDefault acc
        )
        []
        (Dict.toList dict)


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
