module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)

type Route
    = QuoteRoute Int Int
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map QuoteRoute  ( int </> int)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
