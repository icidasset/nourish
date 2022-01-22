module Common exposing (..)

import Html
import Html.Attributes exposing (class)
import MultiSelect


classes : List String -> Html.Attribute msg
classes list =
    class (String.join " " list)


emojiMultiSelectItem : { a | emoji : Maybe String, name : String } -> MultiSelect.Item
emojiMultiSelectItem =
    \i ->
        i.emoji
            |> Maybe.map (\e -> e ++ " ")
            |> Maybe.withDefault ""
            |> (\s -> s ++ i.name)
            |> (\n -> { name = n, value = i.name })
