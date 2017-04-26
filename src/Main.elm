module Main exposing (..)

import Array exposing (Array)
import Html exposing (Html, button, div, text, h1, h2, span, p, article)
import Html.Attributes exposing (class, style, id)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (field)
import Markdown
import Navigation exposing (Location)
import Random
import RemoteData exposing (RemoteData(..), WebData)
import Routing exposing (parseLocation, Route(..))


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


type alias Quote =
    { book : Int
    , section : Int
    , content : List String
    }


type alias Model =
    { quotes : WebData (Array Quote)
    , number : Int
    , route : Route
    }


init : Location -> ( Model, Cmd Msg )
init loc =
    ( { number = 0
      , quotes = Loading
      , route = QuoteRoute "10" "16"
      }
    , getQuotes
    )


type Msg
    = Refresh
    | DataResponse (WebData (Array Quote))
    | NewQuote Int
    | OnLocationChange Location


randomQuote : Cmd Msg
randomQuote =
    Random.generate NewQuote (Random.int 0 27)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Refresh ->
            ( model, randomQuote )

        DataResponse resp ->
            ( { model | quotes = resp }, randomQuote )

        NewQuote i ->
            ( { model | number = i }, Cmd.none )

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

        QuoteRoute book section ->
            case model.quotes of
                NotAsked ->
                    wrap <| p [] [ text "Initializing." ]

                Loading ->
                    wrap <| p [] [ text "Loading..." ]

                Failure err ->
                    wrap <| p [] [ text ("Error: " ++ toString err) ]

                Success quotes ->
                    let
                        bk =
                            String.toInt book
                                |> Result.withDefault 7

                        sec =
                            String.toInt section
                                |> Result.withDefault 59
                    in
                        wrap <| div [] <| Array.toList <| viewQuote quotes bk sec


viewMeta : Quote -> Html Msg
viewMeta q =
    h2 []
        [ text <|
            "Book "
                ++ (toString q.book)
                ++ ", section "
                ++ (toString q.section)
        ]


viewQuote : Array Quote -> Int -> Int -> Array (Html Msg)
viewQuote quotes book section =
    let
        pred q =
            if q.book == book && q.section == section then
                True
            else
                False

        viewQuote_ quote =
            div []
                [ viewMeta quote
                , article []
                    [ quote.content
                        |> String.join "\n\n"
                        |> Markdown.toHtml [ class "content" ]
                    ]
                ]
    in
        quotes
            |> Array.filter pred
            |> Array.map viewQuote_


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


quotesUri : String
quotesUri =
    "https://raw.githubusercontent.com/bsima/aurelius/gh-pages/data/marcus.json"


getQuotes : Cmd Msg
getQuotes =
    Http.get quotesUri decodeQuotes
        |> RemoteData.sendRequest
        |> Cmd.map DataResponse


decodeQuotes : Decode.Decoder (Array Quote)
decodeQuotes =
    Decode.array <|
        Decode.map3 Quote
            (field "book" Decode.int)
            (field "section" Decode.int)
            (field "quote" (Decode.list Decode.string))
