module View exposing (..)

import Html exposing (Html, div, text, h1, p, header, nav, a)
import Html.Attributes exposing (class, id, href, target)
import Html.Events exposing (onClick)
import Markdown
import RemoteData exposing (RemoteData(..), WebData)
import Types exposing (..)


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

failure : a -> Html Msg
failure err =
    wrap <|
        div []
            [ p [] [ text <| "Error: " ++ toString err ]
            , Markdown.toHtml [ class "content" ]
                """
Try refreshing?

If the problem persists, please report
the error at [GitHub](https://github.com/bsima/aurelius/issues)
and I will fix it right away. Thanks!
"""
            ]

notAsked : Html Msg
notAsked =
    wrap <| p [] [ text "Initializing." ]


loading : Html Msg
loading =
    wrap <| p [] [ text "Loading..." ]


webData : (a -> Html Msg) -> RemoteData e a -> Html Msg
webData viewer data =
    case data of
        NotAsked ->
            notAsked

        Loading ->
            loading

        Failure err ->
            failure err

        Success stuff ->
            wrap <| viewer stuff


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
