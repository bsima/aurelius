module Main exposing (..)

import Html exposing (Html, div, text, p)
import Navigation exposing (Location)
import Quote
import Random
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Infix exposing (..)
import Routing exposing (parseLocation, Route(..))
import Types exposing (..)
import Favs exposing (..)
import View


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : Location -> ( Model, Cmd Msg )
init loc =
    ( { quotes = NotAsked
      , route = parseLocation loc
      , favs = NotAsked
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
                            ++ toString quote.book
                            ++ "/"
                            ++ toString quote.section
                    )

                _ ->
                    ( model, Cmd.none )

        FavsResponse resp ->
            ( { model | favs = resp }, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )


root : Model -> Html Msg
root model =
    case model.route of
        NotFoundRoute ->
            View.wrap <| p [] [ text "Not Found..." ]

        Index ->
            View.wrap <| p [] [ text "Loading..." ]

        AllQuotes ->
            case model.quotes of
                NotAsked ->
                    View.notAsked

                Loading ->
                    View.loading

                Failure err ->
                    View.failure err

                Success quotes ->
                    div [] <| List.map Quote.view_ quotes

        QuoteRoute _ _ ->
            View.webData (Quote.view model.route) model.quotes

        Favorites ->
            getFavSet model.quotes model.favs
                |> View.webData (div [] << List.map Quote.view_)

        Ben ->
            model.quotes
                |> View.webData (Favs.filter Favs.bens >> List.map Quote.view_ >> div [])


getFavSet : WebData (List Quote) -> FavSet -> RemoteData Error (List Quote)
getFavSet quotes favs =
    case quotes of
        Loading ->
            Loading

        Failure _ ->
            Failure HttpError

        NotAsked ->
            NotAsked

        Success qs ->
            case favs of
                Success fs ->
                    Success (Favs.filter fs qs)

                Loading ->
                    Loading

                Failure _ ->
                    Failure LocalStorageError

                NotAsked ->
                    NotAsked
