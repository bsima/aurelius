module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = QuoteRoute Int Int
    | Index
    | AllQuotes
    | NotFoundRoute
    | Favorites
    | Ben


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map QuoteRoute (int </> int)
        , map AllQuotes (s "all")
        , map Index top
        , map Ben (s "ben")
        , map Favorites (s "fav")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
