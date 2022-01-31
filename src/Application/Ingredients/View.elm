module Ingredients.View exposing (navigation, view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Extra as Html
import Ingredients.Page exposing (Page(..))
import Kit.Components
import List.Extra as List
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Maybe.Extra as Maybe
import MultiSelect
import Page
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import UI.Kit
import Url
import UserData


view : Page -> Model -> Html Msg
view page model =
    UI.Kit.layout
        []
        (case page of
            Detail context ->
                detail context model

            Edit context ->
                edit context model

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
        Edit _ ->
            UI.Kit.bottomNavButton
                [ A.href "#/ingredients/" ]
                Icons.arrow_back
                "Back to list"

        Index _ ->
            UI.Kit.bottomNavButton
                [ A.href "#/ingredients/new/" ]
                Icons.add
                "Add ingredient"

        _ ->
            UI.Kit.bottomNavButton
                [ A.href "#/ingredients/" ]
                Icons.arrow_back
                "Back to list"



-- DETAIL


detail context model =
    case UserData.findIngredient context model.userData of
        Just ingredient ->
            [ UI.Kit.h1
                []
                [ Html.text ingredient.name ]

            --
            , UI.Kit.buttonContainer
                [ UI.Kit.buttonLinkWithSize
                    Kit.Components.Normal
                    [ { uuid = context.uuid }
                        |> Ingredients.Page.edit
                        |> Page.Ingredients
                        |> Page.toString
                        |> String.append "#"
                        |> A.href
                    ]
                    [ Html.text "Edit" ]

                --
                , UI.Kit.buttonWithSize
                    Kit.Components.Normal
                    [ E.onDoubleClick (RemoveIngredient { uuid = context.uuid }) ]
                    [ Html.text "Double click to remove" ]
                ]
            ]

        Nothing ->
            -- TODO
            []



-- EDIT


edit context model =
    let
        ingredient =
            case context.ingredient of
                Just i ->
                    Just i

                Nothing ->
                    UserData.findIngredient context model.userData
    in
    [ UI.Kit.h1
        []
        [ Html.text "Edit ingredient" ]

    --
    , nameField
        { onInput =
            \name -> GotContextForIngredientEdit { context | name = Just name }
        , value =
            context.name
                |> Maybe.orElse (Maybe.map .name ingredient)
                |> Maybe.withDefault ""
        }

    --
    , emojiField
        { onInput =
            \emoji -> GotContextForIngredientEdit { context | emoji = Just emoji }
        , value =
            context.emoji
                |> Maybe.orElse (Maybe.andThen .emoji ingredient)
                |> Maybe.withDefault ""
        }

    --
    , tagsField
        { available =
            model.tags.ingredients
        , msg =
            \tags ->
                GotContextForIngredientEdit
                    { context | tags = Just (MultiSelect.mapSelected List.sort tags) }
        , value =
            context.tags
                |> Maybe.orElse (Maybe.map (.tags >> MultiSelect.init) ingredient)
                |> Maybe.withDefault (MultiSelect.init [])
        }

    --
    , UI.Kit.buttonWithSize
        Kit.Components.Normal
        [ E.onClick (EditIngredient context) ]
        [ Icons.done 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Save ingredient" ]
        ]
    ]



-- INDEX


index context ingredients model =
    case ingredients of
        [] ->
            indexHeader :: []

        _ ->
            indexHeader :: ingredientsList context ingredients model


indexHeader =
    UI.Kit.h1
        []
        [ Html.text "Ingredients" ]


ingredientsList context ingredients model =
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
            , items = MultiSelect.initItemList model.tags.ingredients
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
                List.isSubsequenceOf
                    tags
                    (List.map String.toLower ingredient.tags)
            )
        |> List.sortBy .name
        |> List.map
            (\ingredient ->
                chunk
                    Html.div
                    [ "mb-2" ]
                    []
                    [ chunk
                        Html.a
                        []
                        [ A.href ("#/ingredients/" ++ Url.percentEncode ingredient.uuid ++ "/") ]
                        [ chunk
                            Html.span
                            [ "mr-2" ]
                            []
                            [ ingredient.emoji
                                |> Maybe.map Html.text
                                |> Maybe.withDefault defaultEmoji
                            ]
                        , Html.text
                            ingredient.name
                        ]
                    ]
            )
        |> chunk
            Html.div
            [ "mt-8"
            ]
            []
    ]


defaultEmoji =
    chunk
        Html.span
        [ "opacity-20" ]
        []
        [ Html.text "❤" ]



-- NEW


new context model =
    [ UI.Kit.h1
        []
        [ Html.text "Add a new ingredient" ]

    --
    , nameField
        { onInput =
            \name -> GotContextForNewIngredient { context | name = name }
        , value = context.name
        }

    --
    , emojiField
        { onInput =
            \emoji -> GotContextForNewIngredient { context | emoji = emoji }
        , value = context.emoji
        }

    --
    , tagsField
        { available =
            model.tags.ingredients
        , msg =
            \tags ->
                GotContextForNewIngredient
                    { context | tags = MultiSelect.mapSelected List.sort tags }
        , value =
            context.tags
        }

    --
    , UI.Kit.buttonWithSize
        Kit.Components.Normal
        [ E.onClick (AddIngredient context) ]
        [ Icons.add 20 Inherit
        , Html.span
            [ A.class "ml-2" ]
            [ Html.text "Add ingredient" ]
        ]
    ]



-- FIELDS


emojiField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
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
            , E.onInput onInput
            , A.placeholder "🥦"
            , A.type_ "text"
            , A.value value
            ]
            []
        ]


nameField { onInput, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "ingredient_name" ]
            [ Html.text "Name" ]
        , UI.Kit.textField
            [ A.id "ingredient_name"
            , E.onInput onInput
            , A.placeholder "Brocolli"
            , A.required True
            , A.type_ "text"
            , A.value value
            ]
            []
        ]


tagsField { available, msg, value } =
    UI.Kit.formField
        [ UI.Kit.label
            [ A.for "ingredient_tags" ]
            [ Html.text "Tags" ]
        , UI.Kit.multiSelect
            { addButton = [ UI.Kit.multiSelectAddButton ]
            , allowCreation = True
            , inputPlaceholder = "Type to find or create a tag"
            , items = MultiSelect.initItemList available
            , msg = msg
            , uid = "selectTags"
            }
            value
        ]
