module UI.Kit exposing (..)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import MultiSelect


bottomNavButton attributes icon text =
    chunk
        Html.a
        [ "bg-green-500"
        , "bg-opacity-10"
        , "font-medium"
        , "flex"
        , "items-center"
        , "justify-center"
        , "px-10"
        , "py-5"
        , "text-center"
        , "text-green-800"
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
        [ "bg-green-600"
        , "bg-opacity-60"
        , "flex"
        , "items-center"
        , "justify-center"
        , "p-4"
        , "rounded"
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
        textFieldClasses


textFieldClasses =
    [ "bg-white"
    , "block"
    , "mb-6"
    , "p-3"
    , "placeholder-gray-400"
    , "placeholder-opacity-60"
    , "rounded"
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


layout =
    chunk
        Html.div
        [ "p-5" ]



-- MULTI SELECT


multiSelect =
    MultiSelect.view
        { addButton =
            [ "inline-block"
            , "items-center"
            , "justify-center"
            , "px-2"
            , "py-2"
            , "rounded"
            , "text-gray-500"
            , "text-opacity-60"
            , "text-sm"
            ]
        , searchContainer =
            []
        , searchInput =
            [ "bg-white"
            , "block"
            , "p-2"
            , "placeholder-gray-400"
            , "placeholder-opacity-60"
            , "relative"
            , "rounded"
            , "shadow"
            , "text-sm"
            , "w-full"
            , "z-10"
            ]
        , searchResultsContainer =
            [ "flex"
            , "font-medium"
            , "mt-2"
            , "text-xs"
            , "text-white"
            ]
        , searchResult =
            [ "bg-gray-400"
            , "bg-opacity-60"
            , "mr-[6px]"
            , "px-[5px]"
            , "py-1"
            , "rounded"
            ]
        , selectedItem =
            [ "bg-gray-500"
            , "bg-opacity-60"
            , "inline-block"
            , "mr-[6px]"
            , "px-[8px]"
            , "py-1"
            , "rounded"
            , "text-sm"
            , "text-white"
            ]
        , selectedItemsContainer =
            [ "flex"
            , "mb-3"
            ]
        }
