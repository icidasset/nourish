module Tailwind exposing (base, dark)

import Html.Attributes exposing (class)


base =
    class


dark =
    prefixed "dark"



-- ㊙️


prefixed prefix =
    String.append (prefix ++ ":") >> class
