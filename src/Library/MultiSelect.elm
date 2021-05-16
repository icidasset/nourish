module MultiSelect exposing (..)

{-| Thanks to `gribouille/elm-multiselect`
-}

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))



-- 🌳


type alias Config msg =
    { inputPlaceholder : String
    , items : List String
    , msg : State -> msg
    , uid : String
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



-- 🛠


selected : State -> List String
selected (State state) =
    state.selected



-- 🖼


type alias Styles =
    { addButton : List String
    , searchContainer : List String
    , searchInput : List String
    , searchResultsContainer : List String
    , searchResult : List String
    , selectedItem : List String
    , selectedItemsContainer : List String
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
                    List.filter (\b -> String.contains a (String.toLower b))

        searchResults =
            cfg.items
                |> List.filter
                    (\i ->
                        not (List.member i stt.selected)
                    )
                |> searchFilter
    in
    chunk
        Html.div
        []
        []
        [ chunk
            Html.div
            styles.selectedItemsContainer
            []
            (List.append
                (List.map
                    (\selectedItem ->
                        chunk
                            Html.button
                            styles.selectedItem
                            [ E.onClick (onSelect cfg stt selectedItem False) ]
                            [ Html.text selectedItem ]
                    )
                    stt.selected
                )
                [ chunk
                    Html.button
                    styles.addButton
                    [ E.onClick (onSearch cfg stt "") ]
                    [ Icons.add_circle 18 Inherit ]
                ]
            )

        --
        , case stt.search of
            Just _ ->
                chunk
                    Html.div
                    styles.searchContainer
                    []
                    [ chunk
                        Html.input
                        styles.searchInput
                        [ A.type_ "text"
                        , A.value (Maybe.withDefault "" stt.search)
                        , A.placeholder cfg.inputPlaceholder
                        , E.onInput (onSearch cfg stt)
                        ]
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
                                            Html.div
                                            styles.searchResult
                                            [ E.onClick (onSelect cfg stt result True) ]
                                            [ Html.text result ]
                                    )
                                    searchResults
                                )
                    ]

            Nothing ->
                Html.text ""
        ]



-- ㊙️


onSearch cfg stt s =
    { stt | search = Just s }
        |> State
        |> cfg.msg


onSelect cfg stt s v =
    if v then
        cfg.msg <| State { stt | selected = s :: stt.selected }

    else
        cfg.msg <| State { stt | selected = List.filter ((/=) s) stt.selected }
