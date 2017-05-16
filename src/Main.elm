module Main exposing (..)

import Html exposing (Html, button, div, text, h1, h2, span, p, article, header, nav, a)
import Html.Attributes exposing (class, style, id, href, target)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Markdown
import Quote
import Random
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Infix exposing (..)
import Routing exposing (parseLocation, Route(..))
import Types exposing (..)


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


init : Location -> ( Model, Cmd Msg )
init loc =
    ( { quotes = Loading
      , route = parseLocation loc
      }
    , Quote.fetch
    )


randomQuote : Cmd Msg
randomQuote =
    Random.generate NewQuote (Random.int 0 27)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Refresh ->
            ( model, randomQuote )

        DataResponse resp ->
            let
                cmd =
                    case model.route of
                        Index ->
                            randomQuote

                        _ ->
                            Cmd.none
            in
                ( { model | quotes = resp }, cmd )

        NewQuote i ->
            case Quote.get i <$> model.quotes of
                Success (Just quote) ->
                    ( { model | route = QuoteRoute quote.book quote.section }
                    , Navigation.newUrl <|
                        "/#/"
                            ++ (toString quote.book)
                            ++ "/"
                            ++ (toString quote.section)
                    )

                _ ->
                    ( model, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )


shoveWebData : (a -> Html Msg) -> WebData a -> Html Msg
shoveWebData viewer data =
    case data of
        NotAsked ->
            wrap <| p [] [ text "Initializing." ]

        Loading ->
            wrap <| p [] [ text "Loading..." ]

        Failure err ->
            wrap <|
                div []
                    [ p [] [ text <| "Error: " ++ (toString err) ]
                    , Markdown.toHtml [ class "content" ]
                        """
Try refreshing?

If the problem persists, please report
the error at [GitHub](https://github.com/bsima/aurelius/issues)
and I will fix it right away. Thanks!
"""
                    ]

        Success stuff ->
            wrap <| viewer stuff


view : Model -> Html Msg
view model =
    case model.route of
        NotFoundRoute ->
            wrap <| p [] [ text "Not Found..." ]

        Index ->
            wrap <| p [] [ text "Loading..." ]

        AllQuotes ->
            model.quotes
                |> shoveWebData (\xs -> div [] <| List.map Quote.view_ xs)

        QuoteRoute book section ->
            shoveWebData (Quote.view model.route) model.quotes


wrap : Html Msg -> Html Msg
wrap kids =
    div []
        [ navbar
        , div
            [ id "content", class "wrapper" ]
            [ h1 [] [ text "Marcus Aurelius" ]
            , p [ class "subtitle" ] [ text "Meditations" ]
            , kids
            ]
        ]


navbar : Html Msg
navbar =
    header [ class "scroll wrapper" ]
        [ nav []
            [ a
                [ href "#"
                , id "refresh"
                , onClick Refresh
                ]
                [ text "Refresh" ]
            , a [ href "#/all" ] [ text "All Quotes" ]
            , a
                [ href "https://goo.gl/forms/zivB95KX91rzcPHT2"
                , target "_blank"
                ]
                [ text "Submit a Quote" ]
            , a
                [ href "https://github.com/bsima/aurelius"
                , target "_blank"
                ]
                [ text "GitHub" ]
            ]
        ]
