module Favs exposing (..)

import Types exposing (..)
import Set


isaFav : Set.Set ( Int, Int ) -> Quote -> Maybe Quote
isaFav favSet quote =
    if Set.member ( quote.book, quote.section ) favSet then
        Just quote
    else
        Nothing


bensFavs : Set.Set ( Int, Int )
bensFavs =
    Set.fromList
        [ ( 2, 1 )
        , ( 2, 5 )
        , ( 3, 5 )
        , ( 3, 10 )
        , ( 4, 7 )
        , ( 5, 1 )
        , ( 5, 20 )
        , ( 5, 22 )
        , ( 5, 37 )
        , ( 6, 2 )
        , ( 6, 6 )
        , ( 6, 13 )
        , ( 6, 39 )
        , ( 6, 45 )
        , ( 6, 48 )
        , ( 6, 53 )
        , ( 7, 22 )
        , ( 7, 59 )
        , ( 7, 69 )
        , ( 9, 4 )
        , ( 9, 5 )
        , ( 9, 40 )
        , ( 10, 1 )
        , ( 10, 16 )
        , ( 10, 27 )
        , ( 10, 29 )
        , ( 11, 7 )
        ]
