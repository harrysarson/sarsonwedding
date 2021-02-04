module Main exposing (main)

import Array
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import GeneratedPorts
import Html.Attributes
import Html.Events
import InteropDefinitions
import Json.Decode
import Lib.InitApp
import Route exposing (Page)
import Svg
import Svg.Attributes
import Task
import Types exposing (..)
import Url
import View


main : Lib.InitApp.ApplicationProgram Json.Decode.Value Model ViewportSize Msg
main =
    Lib.InitApp.application
        { preInit = preInit
        , postInit = postInit
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , view = View.view
        , subscriptions = subscriptions
        , update = update
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize Resize ]


preInit :
    Json.Decode.Value
    -> Url.Url
    -> Browser.Navigation.Key
    -> ( Browser.Document Never, Task.Task Never ViewportSize )
preInit _ _ _ =
    ( { body = [], title = "" }
    , Browser.Dom.getViewport
        |> Task.map extractViewport
    )


postInit : ViewportSize -> Json.Decode.Value -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
postInit viewport flags url key =
    case flags |> GeneratedPorts.decodeFlags of
        Err flagsError ->
            Debug.todo <| Json.Decode.errorToString flagsError

        Ok decodedFlags ->
            changeRouteTo
                (Route.fromUrl url)
                { page = Home
                , static = decodedFlags
                , key = key
                , dims = viewport
                , gui = { navDropDown = False }
                }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Browser.Navigation.pushUrl model.key (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Browser.Navigation.load href
                    )

        ( ChangedUrl _, _ ) ->
            ( model, Cmd.none )

        ( ClickedPage page, { gui } ) ->
            ( { model | page = page, gui = { gui | navDropDown = False } }
            , Route.pushUrl
                model.key
                (case page of
                    Home ->
                        Route.Home

                    Tab { name } ->
                        Route.Tab name

                    NotFound ->
                        Route.Home
                )
            )

        ( Resize width height, _ ) ->
            ( { model | dims = { width = width, height = height } }
            , Cmd.none
            )

        ( ToggleNavDropDown, { gui } ) ->
            ( { model | gui = { gui | navDropDown = not gui.navDropDown } }
            , Cmd.none
            )


extractViewport : Browser.Dom.Viewport -> ViewportSize
extractViewport { viewport } =
    { width = round viewport.width
    , height = round viewport.height
    }


changeRouteTo : Maybe Route.Page -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )

        Just Route.Home ->
            ( { model | page = Home }
            , Cmd.none
            )

        Just (Route.Tab name) ->
            case model.static.pages |> Dict.get name of
                Just page ->
                    let
                        index_ =
                            case model.page of
                                Tab { index } ->
                                    index

                                _ ->
                                    -- TODO(harry): pick a better index here
                                    0
                    in
                    ( { model
                        | page =
                            Tab
                                { index = index_
                                , name = name
                                , text = page.text
                                }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | page = NotFound }
                    , Cmd.none
                    )
