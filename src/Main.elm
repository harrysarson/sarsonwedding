module Main exposing (main)

import Array
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
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
import InteropDefinitions exposing (Flags)
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

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedPage page, { gui } ) ->
            ( { model | page = page, gui = { gui | navDropDown = False } }
            , Cmd.none
            )

        ( Resize width height, _ ) ->
            ( { model | dims = { width = width, height = height } }
            , Cmd.none
            )

        ( ToggleNavDropDown, { gui } ) ->
            ( { model | gui = { gui | navDropDown = not gui.navDropDown } }
            , Cmd.none
            )



-- ( GotProfileMsg subMsg, Profile username profile ) ->
--     Profile.update subMsg profile
--         |> updateWith (Profile username) GotProfileMsg model
-- ( GotArticleMsg subMsg, Article article ) ->
--     Article.update subMsg article
--         |> updateWith Article GotArticleMsg model
-- ( GotEditorMsg subMsg, Editor slug editor ) ->
--     Editor.update subMsg editor
--         |> updateWith (Editor slug) GotEditorMsg model
-- ( GotSession session, Redirect _ ) ->
--     ( Redirect session
--     , Route.replaceUrl (Session.navKey session) Route.Home
--     )
-- ( _, _ ) ->
--     -- Disregard messages that arrived for the wrong page.
--     ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


extractViewport : Browser.Dom.Viewport -> ViewportSize
extractViewport { viewport } =
    { width = round viewport.width
    , height = round viewport.height
    }


px : Int -> String
px value =
    String.fromInt value ++ "px"



-- getImageUrl : Content.WelshPlaces.Place -> Flags -> String
-- getImageUrl place imageUrls =
--     case place of
--         Content.WelshPlaces.Llandovery ->
--             imageUrls.llandovery
--         Content.WelshPlaces.Aberaeron ->
--             imageUrls.aberaeron
--         Content.WelshPlaces.Aberystwyth ->
--             imageUrls.aberystwyth
--         Content.WelshPlaces.Llandudno ->
--             imageUrls.llandudno
--         Content.WelshPlaces.Rhyl ->
--             imageUrls.rhyl
--         Content.WelshPlaces.Bala ->
--             imageUrls.bala
--         Content.WelshPlaces.BetwsyCoed ->
--             imageUrls.betwsyCoed
--         Content.WelshPlaces.Caernarfon ->
--             imageUrls.caernarfon
--         Content.WelshPlaces.Cardiff ->
--             imageUrls.cardiff
--         Content.WelshPlaces.Pwllheli ->
--             imageUrls.pwllheli
--         Content.WelshPlaces.Tywyn ->
--             imageUrls.tywyn
--         Content.WelshPlaces.MerthyrTydfil ->
--             imageUrls.merthyrTydfil
--         Content.WelshPlaces.Abergavenny ->
--             imageUrls.abergavenny
--         Content.WelshPlaces.Manorbier ->
--             imageUrls.manorbier
--         Content.WelshPlaces.PistyllRhaeadr ->
--             imageUrls.pistyllRhaeadr
--         Content.WelshPlaces.Portmeirion ->
--             imageUrls.portmeirion
--         Content.WelshPlaces.Rhossili ->
--             imageUrls.rhossili
--         Content.WelshPlaces.YsbytyCynfyn ->
--             imageUrls.ysbytyCynfyn
--         Content.WelshPlaces.Llanfairpwllgwyngyll ->
--             imageUrls.llanfairpwllgwyngyll
--         Content.WelshPlaces.Llangefni ->
--             imageUrls.llangefni
--         Content.WelshPlaces.Kidwelly ->
--             imageUrls.kidwelly
--         Content.WelshPlaces.Laugharne ->
--             imageUrls.laugharne
--         Content.WelshPlaces.Lampeter ->
--             imageUrls.lampeter
--         Content.WelshPlaces.Llandysul ->
--             imageUrls.llandysul
--         Content.WelshPlaces.Llanrwst ->
--             imageUrls.llanrwst
--         Content.WelshPlaces.Denbigh ->
--             imageUrls.denbigh
--         Content.WelshPlaces.Prestatyn ->
--             imageUrls.prestatyn
--         Content.WelshPlaces.Nefyn ->
--             imageUrls.nefyn


focusInput : Task.Task Browser.Dom.Error ()
focusInput =
    Browser.Dom.focus "wales-place-input"


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
            ( { model | page = Tab name }
            , Cmd.none
            )
