module UI.Kit exposing (..)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))


bottomNavButton attributes icon text =
    chunk
        Html.a
        [ "bg-lime-500"
        , "bg-opacity-10"
        , "font-medium"
        , "flex"
        , "items-center"
        , "justify-center"
        , "px-10"
        , "py-5"
        , "text-center"
        , "text-lime-800"
        , "text-opacity-60"
        , "text-sm"
        ]
        attributes
        [ chunk
            Html.span
            [ "inline-flex"
            , "items-center"
            ]
            []
            [ icon 20 Inherit
            , Html.span
                [ A.class "ml-2" ]
                [ Html.text text ]
            ]
        ]


button =
    chunk
        Html.button
        [ "bg-lime-600"
        , "bg-opacity-50"
        , "flex"
        , "items-center"
        , "justify-center"
        , "p-4"
        , "rounded-md"
        , "text-sm"
        , "text-white"
        , "w-full"
        ]


h1 =
    chunk
        Html.h1
        [ "font-display"
        , "mb-6"
        , "text-3xl"
        ]


textField =
    chunk
        Html.input
        [ "block"
        , "mb-6"
        , "p-3"
        , "rounded-md"
        , "shadow"
        , "text-base"
        , "w-full"
        ]


label =
    chunk
        Html.label
        [ "block"
        , "font-medium"
        , "mb-1"
        , "pb-[2px]"
        , "text-[10px]"
        , "text-gray-400"
        , "tracking-widest"
        , "uppercase"
        ]
