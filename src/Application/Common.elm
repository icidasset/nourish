module Common exposing (..)

import Html
import Html.Attributes exposing (class)
import List.Extra as List
import MultiSelect


classes : List String -> Html.Attribute msg
classes list =
    class (String.join " " list)


enumerate : List String -> String
enumerate items =
    case List.unconsLast items of
        Just ( last, init ) ->
            String.append
                (String.join ", " init)
                (case init of
                    [] ->
                        last

                    _ ->
                        " & " ++ last
                )

        Nothing ->
            ""


emojiMultiSelectItem : { a | emoji : Maybe String, name : String } -> MultiSelect.Item
emojiMultiSelectItem =
    \i ->
        i.emoji
            |> Maybe.map (\e -> e ++ " ")
            |> Maybe.withDefault ""
            |> (\s -> s ++ i.name)
            |> (\n -> { name = n, value = i.name })
