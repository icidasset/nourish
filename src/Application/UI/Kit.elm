module UI.Kit exposing (..)

import Chunky exposing (..)
import Common
import Html exposing (Html)
import Html.Attributes as A
import Kit.Components
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

        -- Dark mode
        ------------
        , "dark:bg-green-500"
        , "dark:bg-opacity-10"
        , "dark:text-green-300"
        , "dark:text-opacity-40"
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
        buttonClasses


buttonWithSize size attributes =
    Kit.Components.button
        size
        (List.append
            [ Common.classes buttonColorClasses ]
            attributes
        )


buttonLink =
    chunk
        Html.a
        buttonClasses


buttonLinkWithSize size attributes =
    Kit.Components.buttonLink
        size
        (List.append
            [ Common.classes buttonColorClasses ]
            attributes
        )


buttonColorClasses =
    [ "bg-green-600"
    , "bg-opacity-60"
    , "text-white"

    -- Dark mode
    ------------
    , "dark:bg-green-400"
    , "dark:bg-opacity-40"
    , "dark:text-green-100"
    , "dark:text-opacity-70"
    ]


buttonClasses =
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

    -- Dark mode
    ------------
    , "dark:bg-green-400"
    , "dark:bg-opacity-40"
    , "dark:text-green-100"
    , "dark:text-opacity-70"
    ]


formField =
    chunk
        Html.div
        [ "mb-6" ]
        []


h1 =
    chunk
        Html.h1
        [ "font-display"
        , "mb-6"
        , "text-3xl"
        ]


h2 =
    chunk
        Html.h2
        [ "font-semibold"
        , "mb-3"
        , "opacity-60"
        , "text-xs"
        , "tracking-wide"
        , "uppercase"
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
        [ "px-5", "pb-40", "pt-5" ]


paragraph =
    chunk
        Html.p
        [ "mb-6"
        , "text-sm"
        ]


textArea =
    chunk
        Html.textarea
        (List.append
            textFieldClasses
            [ "resize-none" ]
        )


textField =
    chunk
        Html.input
        textFieldClasses


textFieldClasses =
    [ "bg-white"
    , "block"
    , "p-3"
    , "placeholder-gray-400"
    , "placeholder-opacity-60"
    , "rounded"
    , "shadow"
    , "text-base"
    , "w-full"

    -- Dark mode
    ------------
    , "dark:bg-gray-800"
    ]



-- MULTI SELECT


multiSelect =
    MultiSelect.view
        { addButton =
            [ "inline-block"
            , "items-center"
            , "justify-center"
            , "mb-[6px]"
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
            , "leading-relaxed"
            , "p-2"
            , "placeholder-gray-400"
            , "placeholder-opacity-60"
            , "relative"
            , "rounded"
            , "shadow"
            , "text-sm"
            , "w-full"
            , "z-10"

            -- Dark mode
            ------------
            , "dark:bg-gray-800"
            ]
        , searchResultsContainer =
            [ "flex"
            , "flex-wrap"
            , "font-medium"
            , "mt-2"
            , "text-xs"
            , "text-white"

            -- Dark mode
            ------------
            , "dark:text-gray-400"
            ]
        , searchResult =
            [ "bg-gray-400"
            , "bg-opacity-60"
            , "mb-[6px]"
            , "mr-[6px]"
            , "px-[5px]"
            , "py-1"
            , "rounded"

            -- Dark mode
            ------------
            , "dark:bg-gray-600"
            , "dark:bg-opacity-60"
            ]
        , selectedItem =
            [ "bg-gray-500"
            , "bg-opacity-60"
            , "inline-block"
            , "mb-[6px]"
            , "mr-[6px]"
            , "px-[8px]"
            , "py-1"
            , "rounded"
            , "text-sm"
            , "text-white"

            -- Dark mode
            ------------
            , "dark:text-gray-300"
            ]
        , selectedItemsContainer =
            [ "flex"
            , "flex-wrap"
            , "mb-3"
            ]
        , selectedItemsEmptyContainer =
            [ "flex"
            , "mb-3"
            , "-ml-2"
            ]
        }
