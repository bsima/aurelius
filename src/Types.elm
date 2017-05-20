module Types exposing (..)

import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..), WebData)
import Routing exposing (Route(..))
import Set exposing (Set(..))
import Http
import LocalStorage


type alias Quote =
    { book : Int
    , section : Int
    , content : List String
    }


type alias FavSet =
    RemoteData Error (Set ( Int, Int ))


type alias Model =
    { quotes : WebData (List Quote)
    , route : Route
    , favs : FavSet
    }


type alias HttpError =
    Http.Error


type alias LocalStorageError =
    LocalStorage.Error


type Error
    = QuoteSelectError Int Int
    | LocalStorageError
    | HttpError


type Msg
    = Refresh
    | DataResponse (WebData (List Quote))
    | NewQuote Int
    | OnLocationChange Location
    | FavsResponse FavSet
