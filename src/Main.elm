module Main exposing (..)

import Html exposing (Html, button, div, text, h1, h2, span, p, article)
import Html.Attributes exposing (class, style, id)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
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


view : Model -> Html Msg
view model =
    case model.route of
        NotFoundRoute ->
            wrap <| p [] [ text "Not Found..." ]

        Index ->
            wrap <| p [] [ text "Loading..." ]

        QuoteRoute book section ->
            case model.quotes of
                NotAsked ->
                    wrap <| p [] [ text "Initializing." ]

                Loading ->
                    wrap <| p [] [ text "Loading..." ]

                Failure err ->
                    wrap <| p [] [ text ("Error: " ++ toString err) ]

                Success quotes ->
                    wrap <| Quote.view quotes model.route


wrap : Html Msg -> Html Msg
wrap kids =
    div [ id "content", class "wrapper" ]
        [ button
            [ class "sans"
            , style
                [ ( "border", "none" )
                , ( "background", "transparent" )
                , ( "margin-top", "1rem" )
                ]
            , onClick Refresh
            ]
            [ text "Refresh" ]
        , h1 [] [ text "Marcus Aurelius" ]
        , p [ class "subtitle" ] [ text "Meditations" ]
        , kids
        ]
