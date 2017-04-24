module Main exposing (..)

import Html exposing (Html, button, div, text, h1, h2, span, p, article)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, style, id)
import Http
import Json.Decode as Decode exposing (field)
import Array exposing (Array)
import Random
import RemoteData exposing (RemoteData(..), WebData)
import Markdown
import Routing exposing (parseLocation, Route(..))
import Navigation exposing (Location)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
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


init : ( Model, Cmd Msg )
init =
    ( { number = 0, quotes = Loading, route = QuoteRoute "10" "16" }
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

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


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
                    wrap <| viewQuote quotes book section



viewMeta : Quote -> Html Msg
viewMeta q =
    h2 []
        [ text <|
            "Book "
                ++ (toString q.book)
                ++ ", section "
                ++ (toString q.section)
        ]


viewQuote : Array Quote -> Int -> Int -> Html Msg
viewQuote quotes book section =
    let
        quote =
            List.head
              (List.filter
                  (\quote -> if quote.book == book then if quote.section == section then True else False else False )
                  quotes)

    in
        div []
            [ viewMeta quote
            , article []
                [ quote.content
                    |> String.join "\n\n"
                    |> Markdown.toHtml [ class "content" ]
                ]
            ]


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
