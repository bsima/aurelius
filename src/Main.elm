module Main exposing (..)

import Html exposing (Html, button, div, text, h1, h2, span, p)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (field)
import Task
import Array exposing (Array)
import Random


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Quote =
    { chapter : Int
    , section : Int
    , content : List String
    }


type alias Model =
    { quotes : Maybe (Array Quote)
    , number : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing 0
    , getQuotes
    )



-- UPDATE


type Msg
    = Refresh
    | FetchQuotes (Result Http.Error (Array Quote))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Refresh ->
            ( { model | number = 5 }, getQuotes )

        FetchQuotes (Err _) ->
            ( model, Cmd.none )

        FetchQuotes (Ok quotes) ->
            ( { model | quotes = Just quotes }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


(>>=) m g =
    case m of
        Nothing ->
            Nothing

        Just x ->
            g x


view : Model -> Html Msg
view model =
    let
        desc q =
            "Chapter " ++ (toString q.chapter) ++ ", section " ++ (toString q.section)

        quote =
            case model.quotes >>= Array.get model.number of
                Just quote ->
                    quote

                Nothing ->
                    { chapter = 0, section = 0, content = ["Error."]}
    in
        div []
            [ h1 [] [ text "Marcus Aurelius" ]
            , h2 [] [ text <| desc quote ]
            , p [] (List.map text quote.content)
            , button [ onClick Refresh ] [ text "Refresh" ]
            ]



-- HTTP


quotesUri : String
quotesUri =
    "https://raw.githubusercontent.com/bsima/aurelius/gh-pages/data/marcus.json"


getQuotes : Cmd Msg
getQuotes =
    Http.send FetchQuotes <| Http.get quotesUri decodeQuotes


decodeQuotes : Decode.Decoder (Array Quote)
decodeQuotes =
    Decode.array <|
        Decode.map3 Quote
            (field "chapter" Decode.int)
            (field "section" Decode.int)
            (field "quote" (Decode.list Decode.string))
