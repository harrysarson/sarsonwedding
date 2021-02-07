module Types exposing (..)

import Array exposing (Array)
import Browser
import Browser.Navigation
import Dict exposing (Dict)
import Url


type alias Flags =
    { pages : Dict String { text : String }
    , images :
        { invite : String
        , sarsonsToBe :
            { portrait : Array String
            , landscape : Array String
            }
        }
    , rsvpUrl : String
    , schedule :
        List
            { time : String
            , text : String
            }
    }


type alias ViewportSize =
    { width : Int
    , height : Int
    }


type Page
    = Home
    | NotFound
    | Tab { index : Int, name : String, text : String }


type alias Model =
    { page : Page
    , static : Flags
    , gui : Gui
    , key : Browser.Navigation.Key
    , dims : ViewportSize
    }


type Msg
    = ClickedPage Page
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | Resize Int Int
    | ToggleNavDropDown


type alias Gui =
    { navDropDown : Bool }
