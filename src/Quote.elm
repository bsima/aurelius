module Quote exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import Http
import RemoteData
import Json.Decode as Decode exposing (field)
import Routing exposing (..)


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


view_ : Quote -> Html Msg
view_ quote =
    div []
        [ viewMeta quote
        , article []
            [ quote.content
                |> String.join "\n\n"
                |> Markdown.toHtml [ class "content" ]
            ]
        ]


view : Route -> List Quote -> Html Msg
view route quotes =
    let
        ( book, section ) =
            case route of
                QuoteRoute book section ->
                    ( book, section )

                _ ->
                    ( 0, 0 )

        helpMsg =
            Markdown.toHtml [ class "content" ]
                """This is an open source project, and not all of the
                   _Meditations_ are transcribed yet. If you would like to add a
                   quote from the _Meditations_, please consider helping out at
                   [the GitHub project](https://github.com/bsima/aurelius). Thanks!"""
    in
        case select book section quotes of
            Ok quote ->
                view_ quote

            Err (QuoteSelectError book section) ->
                div []
                    [ h2 []
                        [ text <|
                            "Could not find Book "
                                ++ (toString book)
                                ++ ", Section "
                                ++ (toString section)
                                ++ ". "
                        ]
                    , article [] [ helpMsg ]
                    ]


viewMeta : Quote -> Html Msg
viewMeta q =
    h2 []
        [ text <|
            "Book "
                ++ (toString q.book)
                ++ ", Section "
                ++ (toString q.section)
        ]


uri : String
uri =
    "https://raw.githubusercontent.com/bsima/aurelius/gh-pages/data/marcus.json"


fetch : Cmd Msg
fetch =
    Http.get uri decode
        |> RemoteData.sendRequest
        |> Cmd.map DataResponse


decode : Decode.Decoder (List Quote)
decode =
    Decode.list <|
        Decode.map3 Quote
            (field "book" Decode.int)
            (field "section" Decode.int)
            (field "quote" (Decode.list Decode.string))
