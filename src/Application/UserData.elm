module UserData exposing (..)

import Ingredient exposing (Ingredient)
import List.Extra as List
import Nourishment exposing (Nourishment)
import RemoteData exposing (RemoteData(..))
import Webnative.Path as Path



-- 🌱


type alias UserData =
    { ingredients : RemoteData String (List Ingredient)
    , nourishments : RemoteData String (List Nourishment)
    , userName : Maybe String
    }


empty =
    { ingredients = Loading
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
    withoutUuid >> mapIngredients



-- INGREDIENTS  🀰  🛠


mapIngredients =
    makeMapper .ingredients (\a u -> { u | ingredients = a })



-- NOURISHMENTS


nourishmentsPath =
    Path.file [ "Nourishments.json" ]


addNourishment nourishment =
    mapNourishments (addToList nourishment)


findNourishment =
    makeFinder .nourishments


removeNourishment =
    withoutUuid >> mapNourishments



-- NOURISHMENTS  🀰  🛠


mapNourishments =
    makeMapper .nourishments (\a u -> { u | nourishments = a })



-- 🛠


addToList : a -> List a -> List a
addToList a list =
    list ++ [ a ]


makeFinder : (UserData -> RemoteData String (List { a | uuid : String })) -> { uuid : String } -> UserData -> Maybe { a | uuid : String }
makeFinder getter { uuid } userData =
    userData
        |> getter
        |> RemoteData.withDefault []
        |> List.find (.uuid >> (==) uuid)


makeMapper : (UserData -> RemoteData String (List a)) -> (RemoteData String (List a) -> UserData -> UserData) -> (List a -> List a) -> UserData -> UserData
makeMapper getter setter fn userData =
    setter (RemoteData.map fn (getter userData)) userData


withoutUuid : { uuid : String } -> List { a | uuid : String } -> List { a | uuid : String }
withoutUuid { uuid } =
    List.filter (.uuid >> (/=) uuid)
