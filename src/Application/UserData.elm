module UserData exposing (..)

import Dict exposing (Dict)
import Ingredient exposing (Ingredient)
import List.Extra as List
import Meal exposing (Meal)
import Nourishment exposing (Nourishment)
import RemoteData exposing (RemoteData(..))
import Webnative.Path as Path



-- 🌱


type alias UserData =
    { ingredients : RemoteData String (List Ingredient)
    , ingredientsEmojiMap : Dict String String
    , meals : RemoteData String (List Meal)
    , nourishments : RemoteData String (List Nourishment)
    , userName : Maybe String
    }


empty =
    { ingredients = Loading
    , ingredientsEmojiMap = Dict.empty
    , meals = Loading
    , nourishments = Loading
    , userName = Nothing
    }



-- INGREDIENTS


ingredientsPath =
    Path.file [ "Ingredients.json" ]


addIngredient ingredient =
    mapIngredients (addToList ingredient)


failedToLoadIngredients =
    failure setIngredients


findIngredient =
    makeFinder .ingredients


loadedIngredients =
    success setIngredients


removeIngredient =
    without >> mapIngredients


replaceIngredient =
    replace >> mapIngredients



-- INGREDIENTS  🀰  🛠


emojiForIngredient : UserData -> String -> Maybe String
emojiForIngredient userdata name =
    Dict.get name userdata.ingredientsEmojiMap


mapIngredients =
    makeMapper
        .ingredients
        setIngredients


setIngredients a u =
    { u
        | ingredients = a
        , ingredientsEmojiMap =
            List.foldl
                (\ingredient dict ->
                    case ingredient.emoji of
                        Just emoji ->
                            Dict.insert ingredient.name emoji dict

                        Nothing ->
                            dict
                )
                Dict.empty
                (RemoteData.withDefault [] a)
    }



-- MEALS


mealsPath =
    Path.file [ "Meals.json" ]


addMeal meal =
    mapMeals (addToList meal)


failedToLoadMeals =
    failure setMeals


findMeal =
    makeFinder .meals


loadedMeals =
    success setMeals


removeMeal =
    without >> mapMeals


replaceMeal =
    replace >> mapMeals



-- MEALS  🀰  🛠


mapMeals =
    makeMapper .meals setMeals


setMeals a u =
    { u | meals = a }



-- NOURISHMENTS


nourishmentsPath =
    Path.file [ "Nourishments.json" ]


addNourishment nourishment =
    mapNourishments (addToList nourishment)


failedToLoadNourishments =
    failure setNourishments


findNourishment =
    makeFinder .nourishments


loadedNourishments =
    success setNourishments


removeNourishment =
    without >> mapNourishments


replaceNourishment =
    replace >> mapNourishments



-- NOURISHMENTS  🀰  🛠


mapNourishments =
    makeMapper .nourishments setNourishments


setNourishments a u =
    { u | nourishments = a }



-- 🛠


addToList : a -> List a -> List a
addToList a list =
    list ++ [ a ]


failure : (RemoteData String (List a) -> UserData -> UserData) -> String -> UserData -> UserData
failure setter err u =
    setter (Failure err) u


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


success : (RemoteData String (List a) -> UserData -> UserData) -> List a -> UserData -> UserData
success setter a u =
    setter (Success a) u


without : { uuid : String } -> List { a | uuid : String } -> List { a | uuid : String }
without { uuid } =
    List.filter (.uuid >> (/=) uuid)
