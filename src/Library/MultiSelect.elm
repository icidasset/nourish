module MultiSelect exposing (..)

{-| Thanks to `gribouille/elm-multiselect`
-}

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Events.Extra as E
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))



-- 🌱


type alias Config msg =
    { addButton : List (Html msg)
    , allowCreation : Bool
    , inputPlaceholder : String
    , items : List Item
    , msg : State -> msg
    , uid : String
    }


type alias Item =
    { name : String
    , value : String
    }


type State
    = State
        { index : Int
        , search : Maybe String
        , selected : List String
        }


init : List String -> State
init val =
    State
        { index = 0
        , search = Nothing
        , selected = val
        }


initItemList : List String -> List Item
initItemList =
    List.map (\v -> { name = v, value = v })



-- 🛠


mapSelected : (List String -> List String) -> State -> State
mapSelected fn (State state) =
    State { state | selected = fn state.selected }


selected : State -> List String
selected (State state) =
    state.selected


selectedItems : List Item -> State -> List Item
selectedItems items (State state) =
    items
        |> List.foldr
            (\item ( a, s ) ->
                let
                    val =
                        item.value
                in
                List.foldr
                    (\x ( acc, sel ) ->
                        if val == x then
                            ( item :: acc, sel )

                        else
                            ( acc, x :: sel )
                    )
                    ( a, [] )
                    s
            )
            ( [], state.selected )
        |> Tuple.first



-- 🖼


type alias Styles =
    { addButton : List String
    , searchContainer : List String
    , searchInput : List String
    , searchResultsContainer : List String
    , searchResult : List String
    , selectedItem : List String
    , selectedItemsContainer : List String
    , selectedItemsEmptyContainer : List String
    }


view : Styles -> Config msg -> State -> Html msg
view styles cfg (State stt) =
    let
        searchFilter =
            case stt.search of
                Nothing ->
                    identity

                Just s ->
                    let
                        a =
                            String.toLower s
                    in
                    List.filter (\b -> String.contains a (String.toLower b.value))

        searchResults =
            cfg.items
                |> List.filter
                    (\i ->
                        not (List.member i.value stt.selected)
                    )
                |> searchFilter
    in
    chunk
        Html.div
        []
        []
        [ chunk
            Html.div
            (case stt.selected of
                [] ->
                    styles.selectedItemsEmptyContainer

                _ ->
                    styles.selectedItemsContainer
            )
            []
            (List.append
                (List.map
                    (\selectedItem ->
                        chunk
                            Html.button
                            styles.selectedItem
                            [ E.onClick (onSelect cfg stt selectedItem.value False) ]
                            [ Html.text selectedItem.name ]
                    )
                    (selectedItems cfg.items <| State stt)
                )
                [ chunk
                    Html.button
                    styles.addButton
                    (case stt.search of
                        Just _ ->
                            [ E.onClick (onHideSearch cfg stt) ]

                        Nothing ->
                            [ E.onClick (onSearch cfg stt "") ]
                    )
                    cfg.addButton
                ]
            )

        --
        , case stt.search of
            Just _ ->
                let
                    value =
                        Maybe.withDefault "" stt.search
                in
                chunk
                    Html.div
                    styles.searchContainer
                    []
                    [ chunk
                        Html.input
                        styles.searchInput
                        (List.append
                            [ A.type_ "search"
                            , A.value value
                            , A.placeholder cfg.inputPlaceholder
                            , E.onInput (onSearch cfg stt)
                            ]
                            (if cfg.allowCreation then
                                [ E.onEnter (onSelect cfg stt value True) ]

                             else
                                []
                            )
                        )
                        []
                    , case searchResults of
                        [] ->
                            Html.text ""

                        _ ->
                            chunk
                                Html.div
                                styles.searchResultsContainer
                                []
                                (List.map
                                    (\result ->
                                        chunk
                                            Html.button
                                            styles.searchResult
                                            [ E.onClick (onSelect cfg stt result.value True) ]
                                            [ Html.text result.name ]
                                    )
                                    searchResults
                                )
                    ]

            Nothing ->
                Html.text ""
        ]



-- ㊙️


onHideSearch cfg stt =
    { stt | search = Nothing }
        |> State
        |> cfg.msg


onSearch cfg stt s =
    { stt | search = Just s }
        |> State
        |> cfg.msg


onSelect cfg stt s v =
    stt.selected
        |> List.filter (String.toLower >> (/=) (String.toLower s))
        |> (if v then
                (::) s

            else
                identity
           )
        |> (\new -> { stt | selected = new })
        |> State
        |> cfg.msg
