module Route exposing (Page(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



-- ROUTING


type Page
    = Home
    | Tab String


parser : Parser (Page -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Tab (s "info" </> string)
        ]



-- PUBLIC HELPERS


href : Page -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Page -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Page
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser



-- INTERNAL


routeToString : Page -> String
routeToString page =
    "#/" ++ String.join "/" (routeToPieces page)


routeToPieces : Page -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Tab name ->
            [ "info", name ]
