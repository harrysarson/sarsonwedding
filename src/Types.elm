module Types exposing (..)

import Browser
import Browser.Navigation
import InteropDefinitions exposing (Flags)
import Url


type alias ViewportSize =
    { width : Int
    , height : Int
    }


type Page
    = Home
    | NotFound
    | Tab String


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
