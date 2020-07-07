module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, article, button, div, h1, h2, header, nav, p, span, text)
import Html.Attributes exposing (class, href, id, style, target)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Markdown
import Random
import Random.List
import RemoteData exposing (RemoteData(..), WebData)
import Set
import Url
import Url.Builder
import Url.Parser exposing ((</>))


type Route
    = QuoteRoute Int Int
    | Index
    | AllQuotes
    | NotFound
    | Ben


routes : Url.Parser.Parser (Route -> a) a
routes = Url.Parser.s "#" </>
    Url.Parser.oneOf
        [ Url.Parser.map QuoteRoute (Url.Parser.int </> Url.Parser.int)
        , Url.Parser.map AllQuotes (Url.Parser.s "all")
        , Url.Parser.map Index Url.Parser.top
        , Url.Parser.map Ben (Url.Parser.s "ben")
        ]


type alias Model =
    { quotes : WebData (List Quote)
    , key : Nav.Key
    , route : Route
    }


type Error
    = QuoteSelectError Int Int


type Msg
    = Refresh
    | DataResponse (WebData (List Quote))
    | NewQuote ( Maybe Int, List Int )
    | Goto Route
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest


type alias Quote =
    { book : Int
    , section : Int
    , content : List String
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { quotes = Loading
      , key = key
      , route = Index
      }
    , fetch
    )


randomQuote : Model -> Cmd Msg
randomQuote model =
    RemoteData.withDefault [] model.quotes
        |> List.length
        |> List.range 0
        |> Random.List.choose
        |> Random.generate NewQuote


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Refresh ->
            ( model, randomQuote model )

        DataResponse resp ->
            let
                cmd =
                    case model.route of
                        Index ->
                            randomQuote model

                        _ ->
                            Cmd.none
            in
            ( { model | quotes = resp }, cmd )

        NewQuote ( Nothing, _ ) ->
            ( model, Cmd.none )

        NewQuote ( Just i, _ ) ->
            case RemoteData.map (get i) model.quotes of
                Success (Just quote) ->
                    ( { model | route = QuoteRoute quote.book quote.section }
                    , Url.Builder.absolute
                        [ "#"
                        , String.fromInt quote.book
                        , String.fromInt quote.section
                        ]
                        []
                        |> Nav.pushUrl model.key
                    )

                _ ->
                    ( model, Cmd.none )

        Goto route ->
            ( { model | route = route }, Cmd.none )

        UrlChanged url ->
            -- not sure how to use this, the parser always seems to fail, so
            -- I'll just ignore this action. anyway it works.
            case Url.Parser.parse routes url of
                Just route ->
                    ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )


shoveWebData : (a -> Html Msg) -> WebData a -> Html Msg
shoveWebData viewer data =
    case data of
        NotAsked ->
            p [] [ text "Initializing." ]

        Loading ->
            p [] [ text "Loading..." ]

        Failure err ->
            div []
                [ p [] [ text <| "Error: " ] -- ++ err ]
                , div [ class "content" ] <|
                    Markdown.toHtml Nothing
                        """
Try refreshing?

If the problem persists, please report
the error at [GitHub](https://github.com/bsima/aurelius/issues)
and I will fix it right away. Thanks!
"""
                ]

        Success stuff ->
            viewer stuff


view : Model -> Browser.Document Msg
view model =
    case model.route of
        Index ->
            wrap <| p [] [ text "Loading..." ]

        AllQuotes ->
            model.quotes
                |> shoveWebData (\xs -> div [] <| List.map quoteView_ xs)
                |> wrap

        QuoteRoute book section ->
            shoveWebData (quoteView book section) model.quotes
                |> wrap

        Ben ->
            model.quotes
                |> shoveWebData (List.filterMap isaFav >> List.map quoteView_ >> div [])
                |> wrap

        NotFound ->
            wrap <| p [] [ text "Not Found..." ]


wrap : Html Msg -> Browser.Document Msg
wrap kids =
    { title = "Marcus Aurelius"
    , body =
        [ div []
            [ navbar
            , div
                [ id "content", class "wrapper" ]
                [ h1 [] [ text "Marcus Aurelius" ]
                , p [ class "subtitle" ] [ text "Meditations" ]
                , kids
                ]
            ]
        ]
    }


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
            , a [ href "#", onClick <| Goto AllQuotes ] [ text "All Quotes" ]
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


isaFav : Quote -> Maybe Quote
isaFav quote =
    if Set.member ( quote.book, quote.section ) bensFavs then
        Just quote

    else
        Nothing


bensFavs : Set.Set ( Int, Int )
bensFavs =
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


listGet : Int -> List a -> Maybe a
listGet i =
    List.head << List.drop i


get : Int -> List Quote -> Maybe Quote
get i quotes =
    listGet i quotes


select : Int -> Int -> List Quote -> Result Error Quote
select book section quotes =
    let
        pred q =
            if q.book == book && q.section == section then
                True

            else
                False
    in
    case List.filter pred quotes of
        x :: xs ->
            Result.Ok x

        _ ->
            Result.Err (QuoteSelectError book section)


quoteView_ : Quote -> Html Msg
quoteView_ quote =
    div []
        [ viewMeta quote
        , quote.content
            |> String.join "\n\n"
            |> Markdown.toHtml Nothing
            |> article [ class "content" ]
        ]


quoteView : Int -> Int -> List Quote -> Html Msg
quoteView book section quotes =
    let
        helpMsg =
            Markdown.toHtml Nothing
                """This is an open source project, and not all of the
                   _Meditations_ are transcribed yet. If you would like to add a
                   quote from the _Meditations_, please consider helping out at
                   [the GitHub project](https://github.com/bsima/aurelius). Thanks!"""
    in
    case select book section quotes of
        Ok quote ->
            quoteView_ quote

        Err (QuoteSelectError b s) ->
            div []
                [ h2 []
                    [ text <|
                        "Could not find Book "
                            ++ String.fromInt b
                            ++ ", Section "
                            ++ String.fromInt s
                            ++ ". "
                    ]
                , article [ class "content" ] helpMsg
                ]


viewMeta : Quote -> Html Msg
viewMeta q =
    h2 []
        [ text <|
            "Book "
                ++ String.fromInt q.book
                ++ ", Section "
                ++ String.fromInt q.section
        ]


uri : String
uri =
    "https://raw.githubusercontent.com/bsima/aurelius/gh-pages/data/marcus.json"


fetch : Cmd Msg
fetch =
    Http.get
        { url = "https://raw.githubusercontent.com/bsima/aurelius/gh-pages/data/marcus.json"
        , expect = Http.expectJson (RemoteData.fromResult >> DataResponse) decode
        }


decode : Decode.Decoder (List Quote)
decode =
    Decode.list <|
        Decode.map3 Quote
            (Decode.field "book" Decode.int)
            (Decode.field "section" Decode.int)
            (Decode.field "quote" (Decode.list Decode.string))
