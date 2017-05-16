module Types exposing (..)

import Navigation exposing (Location)
import RemoteData exposing (RemoteData(..), WebData)
import Routing exposing (Route(..))


type alias Quote =
    { book : Int
    , section : Int
    , content : List String
    }


type alias Model =
    { quotes : WebData (List Quote)
    , route : Route
    }


type Error
    = QuoteSelectError Int Int


type Msg
    = Refresh
    | DataResponse (WebData (List Quote))
    | NewQuote Int
    | OnLocationChange Location
