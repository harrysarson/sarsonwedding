module Route exposing (Page(..), fromUrl, href, pushUrl, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Builder
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)



-- ROUTING


type Page
    = Home
    | Tab String


parser : Parser (Page -> a) a
parser =
    oneOf
        [ Parser.map Home (s "sarsonwedding")
        , Parser.map Tab (s "sarsonwedding" </> s "info" </> Parser.custom "PAGE" Url.percentDecode)
        ]



-- PUBLIC HELPERS


href : Page -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Page -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


pushUrl : Nav.Key -> Page -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (routeToString route)


fromUrl : Url -> Maybe Page
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    url
        |> Parser.parse parser



-- INTERNAL


routeToString : Page -> String
routeToString page =
    Url.Builder.absolute (routeToPieces page) []


routeToPieces : Page -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Tab name ->
            [ "info", Url.percentEncode name ]
