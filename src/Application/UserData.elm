module UserData exposing (..)

import Ingredient exposing (Ingredient)
import List.Extra as List
import Meal exposing (Meal)
import Nourishment exposing (Nourishment)
import RemoteData exposing (RemoteData(..))
import Webnative.Path as Path



-- 🌱


type alias UserData =
    { ingredients : RemoteData String (List Ingredient)
    , meals : RemoteData String (List Meal)
    , nourishments : RemoteData String (List Nourishment)
    , userName : Maybe String
    }


empty =
    { ingredients = Loading
    , meals = Loading
    , nourishments = Loading
    , userName = Nothing
    }



-- INGREDIENTS


ingredientsPath =
    Path.file [ "Ingredients.json" ]


addIngredient ingredient =
    mapIngredients (addToList ingredient)


findIngredient =
    makeFinder .ingredients


removeIngredient =
    without >> mapIngredients


replaceIngredient =
    replace >> mapIngredients



-- INGREDIENTS  🀰  🛠


mapIngredients =
    makeMapper .ingredients (\a u -> { u | ingredients = a })



-- MEALS


mealsPath =
    Path.file [ "Meals.json" ]


addMeal meal =
    mapMeals (addToList meal)


findMeal =
    makeFinder .meals


removeMeal =
    without >> mapMeals


replaceMeal =
    replace >> mapMeals



-- MEALS  🀰  🛠


mapMeals =
    makeMapper .meals (\a u -> { u | meals = a })



-- NOURISHMENTS


nourishmentsPath =
    Path.file [ "Nourishments.json" ]


addNourishment nourishment =
    mapNourishments (addToList nourishment)


findNourishment =
    makeFinder .nourishments


removeNourishment =
    without >> mapNourishments


replaceNourishment =
    replace >> mapNourishments



-- NOURISHMENTS  🀰  🛠


mapNourishments =
    makeMapper .nourishments (\a u -> { u | nourishments = a })



-- 🛠


addToList : a -> List a -> List a
addToList a list =
    list ++ [ a ]


makeFinder : (UserData -> RemoteData String (List { a | uuid : String })) -> { b | uuid : String } -> UserData -> Maybe { a | uuid : String }
makeFinder getter { uuid } userData =
    userData
        |> getter
        |> RemoteData.withDefault []
        |> List.find (.uuid >> (==) uuid)


makeMapper : (UserData -> RemoteData String (List a)) -> (RemoteData String (List a) -> UserData -> UserData) -> (List a -> List a) -> UserData -> UserData
makeMapper getter setter fn userData =
    setter (RemoteData.map fn (getter userData)) userData


replace : { uuid : String, unit : { a | uuid : String } } -> List { a | uuid : String } -> List { a | uuid : String }
replace { unit, uuid } =
    List.map
        (\a ->
            if a.uuid == uuid then
                unit

            else
                a
        )


without : { uuid : String } -> List { a | uuid : String } -> List { a | uuid : String }
without { uuid } =
    List.filter (.uuid >> (/=) uuid)
