module Ingredients.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Ingredients.Page exposing (Page(..))
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import MultiSelect
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import UI.Kit


view : Page -> Model -> Html Msg
view page model =
    UI.Kit.layout
        []
        (case page of
            Index context ->
                case model.userData.ingredients of
                    NotAsked ->
                        []

                    Loading ->
                        -- TODO
                        [ Html.text "Loading" ]

                    Failure error ->
                        -- TODO
                        [ Html.text "Failed to load user data."
                        , Html.br [] []
                        , Html.text error
                        ]

                    Success ingredients ->
                        index context ingredients model

            New context ->
                new context model
        )



-- NAVIGATION


navigation : Page -> Html Msg
navigation page =
    case page of
        Index _ ->
            UI.Kit.bottomNavButton
                [ A.href "/ingredients/new/" ]
                Icons.add
                "Add ingredient"

        New _ ->
            UI.Kit.bottomNavButton
                [ A.href "../" ]
                Icons.arrow_back
                "Back to list"



-- INDEX


index context ingredients _ =
    case ingredients of
        [] ->
            indexHeader :: []

        _ ->
            indexHeader :: ingredientsList context ingredients


indexHeader =
    UI.Kit.h1
        []
        [ Html.text "Ingredients" ]


ingredientsList context ingredients =
    let
        tags =
            context.filter
                |> MultiSelect.selected
                |> List.map String.toLower
    in
    [ chunk
        Html.div
        [ "mt-6"
        ]
        []
        [ UI.Kit.multiSelect
            { addButton =
                [ Icons.filter_alt 18 Inherit ]
            , allowCreation = False
            , inputPlaceholder = "Search tags"
            , items = List.sort [ "Vegetable", "Legume", "Fruit" ]
            , msg =
                \filter ->
                    GotContextForIngredientsIndex
                        { context | filter = MultiSelect.mapSelected List.sort filter }
            , uid = "selectTags"
            }
            context.filter
        ]

    --
    , ingredients
        |> List.filter
            (\ingredient ->
                isSubsequenceOf
                    tags
                    (List.map String.toLower ingredient.tags)
            )
        |> List.map
            (\ingredient ->
                chunk
                    Html.div
                    [ "mb-2" ]
                    []
                    [ chunk
                        Html.span
                        [ "mr-2" ]
                        []
                        [ ingredient.emoji
                            |> Maybe.withDefault "🤍"
                            |> Html.text
                        ]
                    , Html.text
                        ingredient.name
                    ]
            )
        |> chunk
            Html.div
            [ "mt-8"
            ]
            []
    ]



-- NEW


new context _ =
    [ UI.Kit.h1
        []
        [ Html.text "Add a new ingredient" ]

    --
    , UI.Kit.label
        [ A.for "ingredient_name" ]
        [ Html.text "Name" ]
    , UI.Kit.textField
        [ A.id "ingredient_name"
        , E.onInput
            (\name ->
                GotContextForNewIngredient
                    { context | name = name }
            )
        , A.placeholder "Brocolli"
        , A.required True
        , A.type_ "text"
        , A.value context.name
        ]
        []

    --
    , UI.Kit.label
        [ A.for "ingredient_emoji" ]
        [ Html.text "Emoji" ]
    , chunk
        Html.input
        (List.map
            (\c ->
                case c of
                    "placeholder-opacity-60" ->
                        "placeholder-opacity-30"

                    _ ->
                        c
            )
            UI.Kit.textFieldClasses
        )
        -- TODO: https://package.elm-lang.org/packages/BrianHicks/elm-string-graphemes/latest/String-Graphemes#length
        [ A.id "ingredient_emoji"
        , E.onInput
            (\emoji ->
                GotContextForNewIngredient
                    { context | emoji = emoji }
            )
        , A.placeholder "🥦"
        , A.type_ "text"
        , A.value context.emoji
        ]
        []

    --
    , UI.Kit.label
        [ A.for "ingredient_tags" ]
        [ Html.text "Tags" ]
    , chunk
        Html.div
        [ "mb-6" ]
        []
        [ UI.Kit.multiSelect
            { addButton = [ Icons.add_circle 18 Inherit ]
            , allowCreation = True
            , inputPlaceholder = "Type to find or create a tag"
            , items = List.sort [ "Vegetable", "Legume", "Fruit" ]
            , msg =
                \tags ->
                    GotContextForNewIngredient
                        { context | tags = MultiSelect.mapSelected List.sort tags }
            , uid = "selectTags"
            }
            context.tags
        ]

    --
    , UI.Kit.button
        [ E.onClick (AddIngredient context) ]
        [ Icons.add 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Add ingredient" ]
        ]
    ]


isSubsequenceOf : List a -> List a -> Bool
isSubsequenceOf subseq list =
    case ( subseq, list ) of
        ( [], _ ) ->
            True

        ( _, [] ) ->
            False

        ( x :: xs, y :: ys ) ->
            if x == y then
                isSubsequenceOf xs ys

            else
                isSubsequenceOf subseq ys
