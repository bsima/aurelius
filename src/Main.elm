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
    }


init : ( Model, Cmd Msg )
init =
    ( { number = 0, quotes = Loading }
    , getQuotes
    )


type Msg
    = Refresh
    | DataResponse (WebData (Array Quote))
    | NewQuote Int


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model.quotes of
        NotAsked ->
            wrap <| p [] [ text "Initializing." ]

        Loading ->
            wrap <| p [] [ text "Loading..." ]

        Failure err ->
            wrap <| p [] [ text ("Error: " ++ toString err) ]

        Success quotes ->
            wrap <| viewQuote model.number quotes


viewMeta : Quote -> Html Msg
viewMeta q =
    h2 []
        [ text <|
            "Book "
                ++ (toString q.book)
                ++ ", section "
                ++ (toString q.section)
        ]


viewQuote : Int -> Array Quote -> Html Msg
viewQuote num quotes =
    let
        quote =
            case Array.get num quotes of
                Just quote ->
                    quote

                Nothing ->
                    { book = 0
                    , section = 0
                    , content = [ "Error selecting quote. Please refresh" ]
                    }
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
