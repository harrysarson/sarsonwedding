module Main exposing (main)

import Bitwise
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import GeneratedPorts
import Json.Decode
import Route
import Task
import Types exposing (..)
import Url
import View


main : Platform.Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
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



-- preInit :
--     Json.Decode.Value
--     -> Url.Url
--     -> Browser.Navigation.Key
--     -> ( Browser.Document Never, Task.Task Never ViewportSize )
-- preInit _ _ _ =
--     ( { body = [], title = "" }
--     , Browser.Dom.getViewport
--         |> Task.map extractViewport
--     )


init : Json.Decode.Value -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    case flags |> GeneratedPorts.decodeFlags of
        Err _ ->
            -- Crash the stack, ts interop + runtime checking of json confirms
            -- we cannot hit this.
            (\() -> init flags url key)
                ()

        Ok decodedFlags ->
            changeRouteTo
                (Route.fromUrl url)
                { page = Home
                , static = decodedFlags
                , key = key
                , dims = Nothing
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
            ( { model | dims = Just { width = width, height = height } }
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
    let
        initCmd =
            Browser.Dom.getViewport
                |> Task.map extractViewport
                |> Task.perform (\{ width, height } -> Resize width height)
    in
    Tuple.mapSecond
        (\cmd -> Cmd.batch [ cmd, initCmd ])
        (case maybeRoute of
            Nothing ->
                ( { model | page = NotFound }
                , Cmd.none
                )

            Just Route.Home ->
                ( { model | page = Home }
                , Cmd.none
                )

            Just (Route.Tab name) ->
                case
                    model.static.pages
                        |> Dict.toList
                        |> List.indexedMap (\i ( k, v ) -> ( i, k, v ))
                        |> List.filter (\( _, k, _ ) -> k == name)
                of
                    ( index, _, page ) :: _ ->
                        ( { model
                            | page =
                                Tab
                                    { index = index
                                    , name = name
                                    , text = page.text
                                    }
                          }
                        , focusCmd
                        )

                    [] ->
                        ( { model | page = NotFound }
                        , Cmd.none
                        )
        )


focusCmd : Cmd Msg
focusCmd =
    Task.attempt (\_ -> NoOp) (Browser.Dom.focus "focus-me")
