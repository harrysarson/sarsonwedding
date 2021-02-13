module Main exposing (main)

import Bitwise
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import GeneratedPorts
import Json.Decode
import Lib.InitApp
import Route
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
subscriptions _ =
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
        Err _ ->
            -- Crash the stack, ts interop + runtime checking of json confirms
            -- we cannot hit this.
            (\() -> postInit viewport flags url key)
                ()

        Ok decodedFlags ->
            changeRouteTo
                (Route.fromUrl url)
                { page = Home
                , static = decodedFlags
                , key = key
                , dims = viewport
                , gui = { navDropDown = False, easter = 0 }
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
            , Cmd.batch
                [ Route.pushUrl
                    model.key
                    (case page of
                        Home ->
                            Route.Home

                        Tab { name } ->
                            Route.Tab name

                        NotFound ->
                            Route.Home
                    )
                , focusCmd
                ]
            )

        ( Resize width height, _ ) ->
            ( { model | dims = { width = width, height = height } }
            , Cmd.none
            )

        ( ToggleNavDropDown, { gui } ) ->
            ( { model | gui = { gui | navDropDown = not gui.navDropDown } }
            , Cmd.none
            )

        ( ToggleEaster, { gui } ) ->
            let
                newEaster =
                    gui.easter + 1 |> Bitwise.and 3
            in
            ( { model | gui = { gui | easter = newEaster } }
            , if newEaster == 3 then
                focusCmd

              else
                Cmd.none
            )

        ( NoOp, _ ) ->
            ( model
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
                    , focusCmd
                    )

                Nothing ->
                    ( { model | page = NotFound }
                    , Cmd.none
                    )


focusCmd : Cmd Msg
focusCmd =
    Task.attempt (\_ -> NoOp) (Browser.Dom.focus "focus-me")
