module Favs exposing (isa, filter, bens)

import Types exposing (Quote)
import Set exposing (Set)


{-| Check if the quote is a favorite, if its in the set of favs
-}
isa : Set ( Int, Int ) -> Quote -> Maybe Quote
isa favSet quote =
    if Set.member ( quote.book, quote.section ) favSet then
        Just quote
    else
        Nothing


{-| Really bad filter function, but it gets the job done
-}
filter : Set ( Int, Int ) -> List Quote -> List Quote
filter favSet =
    List.filterMap (isa favSet)


{-| My favorites :D
-}
bens : Set.Set ( Int, Int )
bens =
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
