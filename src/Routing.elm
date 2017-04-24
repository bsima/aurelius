module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)

type Route
    = QuoteRoute String String -- Strings are for Book and Section numbers.
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map QuoteRoute  ( string </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
