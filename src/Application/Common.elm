module Common exposing (..)

import MultiSelect


emojiMultiSelectItem : { a | emoji : Maybe String, name : String } -> MultiSelect.Item
emojiMultiSelectItem =
    \i ->
        i.emoji
            |> Maybe.map (\e -> e ++ " ")
            |> Maybe.withDefault ""
            |> (\s -> s ++ i.name)
            |> (\n -> { name = n, value = i.name })
