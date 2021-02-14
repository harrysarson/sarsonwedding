module View exposing (colors, view)

import Array
import Browser
import Dict
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes
import Markdown.Parser
import Markdown.Renderer
import Tuple
import Types exposing (..)


padding : Int
padding =
    4


baseFont : Int
baseFont =
    14


bannerSize : Int
bannerSize =
    baseFont * 5


maxContentWidth =
    baseFont * 35


fonts =
    { posh =
        Font.family
            [ Font.typeface "Great Vibes"
            , Font.typeface "cursive"
            ]
    }


colors : { navy : Color, white : Color, black : Color, grey : Color, lightGrey : Color, pink : Color, washedoutPink : Color }
colors =
    { navy = E.rgb255 0x0D 0x16 0x2D
    , white = E.rgb 1 1 1
    , black = E.rgb 0 0 0
    , grey = E.rgb 0.6 0.6 0.6
    , lightGrey = E.rgb255 0xF1 0xF1 0xF1
    , pink = E.rgb255 245 169 173
    , washedoutPink = E.rgb255 0xFF 0xEA 0xFF
    }


defaultShadow : { offset : ( number, number ), size : Float, blur : Float, color : Color }
defaultShadow =
    { offset = ( 0, 1 )
    , size = toFloat padding
    , blur = toFloat padding
    , color = E.rgba 0 0 0 0.1
    }


bannerBar : List (Attribute msg) -> Element msg -> Element msg
bannerBar props content =
    E.el
        (List.concat
            [ [ E.width E.fill
              , Background.color colors.navy
              , Font.center
              , E.height (bannerSize |> E.px)
              , Border.shadow defaultShadow
              ]
            , props
            ]
        )
        content


header : Model -> Element Msg
header model =
    let
        navs : List ( String, Types.Page )
        navs =
            [ [ ( "home", Home ) ]
            , model.static.pages
                |> Dict.toList
                |> List.indexedMap
                    (\index ( name, { text } ) ->
                        ( name
                        , Tab
                            { index = index
                            , name = name
                            , text = text
                            }
                        )
                    )
            ]
                |> List.concat
                |> List.map (Tuple.mapFirst String.toUpper)

        buttonSize =
            baseFont * 4

        fontSize =
            baseFont * 3

        buttonGui props el =
            E.column
                ([ [ E.centerX
                   , E.centerY
                   , E.spaceEvenly
                   , E.pointer
                   , E.htmlAttribute (Html.Attributes.attribute "style" "user-select:none")
                   , Background.color colors.white
                   , Border.rounded padding
                   ]
                 , props
                 ]
                    |> List.concat
                )
                el

        button =
            buttonGui
                [ Font.size fontSize
                , Font.color colors.pink
                , E.height (buttonSize |> E.px)
                , E.width (buttonSize |> E.px)
                , E.paddingXY (buttonSize // 6) (buttonSize // 5)
                , Events.onClick ToggleNavDropDown
                , E.mouseOver
                    [ Font.color colors.grey ]
                ]
                (List.concat
                    [ List.repeat
                        3
                        (E.el
                            [ E.width E.fill
                            , Border.widthXY 0 2
                            , Border.rounded 2
                            ]
                            E.none
                        )
                    , [ E.el
                            [ E.centerX
                            , Font.size (buttonSize // 5)
                            , Font.color colors.grey
                            , Font.bold
                            ]
                            (E.text "menu")
                      ]
                    ]
                )

        dropDown props skip =
            E.column
                ([ [ Region.navigation
                   , Background.color colors.navy
                   , E.paddingEach
                        { bottom = baseFont
                        , left = 0
                        , right = 0
                        , top = 0
                        }
                   , Border.shadow defaultShadow
                   ]
                 , props
                 ]
                    |> List.concat
                )
                (navs
                    |> List.drop skip
                    |> List.indexedMap (\index ( name, onClick ) -> navRowFor name onClick (index /= 0))
                )
    in
    case model.dims of
        Just dims ->
            case (E.classifyDevice dims).orientation of
                E.Landscape ->
                    let
                        linkWidth =
                            buttonSize * 4

                        els =
                            floor (toFloat dims.width / toFloat (linkWidth + buttonSize) - 0.5)
                    in
                    bannerBar
                        (if model.gui.navDropDown then
                            [ E.below (dropDown [ E.alignRight, E.width (linkWidth * 2 |> E.px) ] els) ]

                         else
                            []
                        )
                        (E.row
                            [ E.width E.fill
                            , E.height E.fill
                            , E.paddingXY buttonSize 0
                            , E.spacing buttonSize
                            , E.clipX
                            , Region.navigation
                            , Font.color colors.white
                            , E.inFront
                                (E.el
                                    [ E.height E.fill
                                    , E.alignRight
                                    , E.paddingXY buttonSize 0
                                    ]
                                    button
                                )
                            ]
                            (navs
                                |> List.take els
                                |> List.map
                                    (\( name, onClick ) ->
                                        buttonGui
                                            [ E.height (buttonSize |> E.px)
                                            , E.width (linkWidth |> E.px)
                                            , E.alignLeft
                                            , E.paddingXY (buttonSize // 6) (buttonSize // 4)
                                            , Font.color colors.navy
                                            , Font.center
                                            , E.mouseOver
                                                [ Font.color colors.pink ]
                                            , Events.onClick (ClickedPage onClick)
                                            ]
                                            [ E.el [ E.centerX, E.centerY ] (E.text name) ]
                                    )
                            )
                        )

                E.Portrait ->
                    bannerBar
                        (if model.gui.navDropDown then
                            [ E.below
                                (dropDown
                                    [ E.width E.fill ]
                                    0
                                )
                            ]

                         else
                            []
                        )
                        button

        Nothing ->
            bannerBar
                []
                E.none


footer : Model -> Element Msg
footer model =
    bannerBar
        [ E.inFront
            (E.el
                [ E.moveDown (toFloat bannerSize)
                , E.width E.fill
                , Background.color colors.navy
                , Font.center
                , E.height (bannerSize |> E.px)
                ]
                E.none
            )
        , E.alignBottom
        ]
        (E.link
            [ E.centerX
            , E.centerY
            , E.pointer
            , Font.size (baseFont * 2)
            , Font.color colors.lightGrey
            , E.mouseOver
                [ Font.color colors.pink ]
            ]
            { url = model.static.rsvpUrl, label = E.text "RSVP Here" }
        )


homeOrTab : List (Attribute msg) -> List (Element msg) -> Element msg
homeOrTab attr els =
    E.column
        (List.concat
            [ [ E.width E.fill
              , E.paddingEach
                    { bottom = baseFont * 3
                    , left = baseFont
                    , right = baseFont
                    , top = baseFont * 3
                    }
              , E.spacing (baseFont * 3)
              ]
            , attr
            ]
        )
        els


home : Model -> Element Msg
home model =
    let
        nameAttrs =
            [ E.centerX
            , Font.size (baseFont * 3)
            , fonts.posh
            ]
    in
    homeOrTab
        []
        [ E.column
            [ E.centerX
            , E.spacing baseFont
            ]
            [ E.el nameAttrs (E.text "Harry Sarson")
            , E.el
                [ E.centerX
                , Font.size (baseFont * 2)
                ]
                (E.text "and")
            , E.el nameAttrs (E.text "Sophie Burke")
            ]
        , E.el
            [ E.centerX
            , Font.size (baseFont * 2)
            ]
            (E.text "Saturday 5th June 2021")
        , E.el
            [ E.width (E.maximum maxContentWidth E.fill)
            , E.padding (padding * 3)
            , E.spacing (padding * 3)
            , E.centerX
            , Border.shadow defaultShadow
            , Background.color colors.navy
            , Font.color colors.white
            ]
            (E.table
                [ E.spacing baseFont
                , Font.size baseFont
                ]
                { data = model.static.schedule
                , columns =
                    [ { header = E.el [ Font.size (baseFont + 4), Font.bold ] (E.text "Schedule")
                      , width = fill
                      , view =
                            \{ time } ->
                                E.text time
                      }
                    , { header = E.none
                      , width = fill
                      , view =
                            \{ text } ->
                                E.text text
                      }
                    ]
                }
            )
        , case model.static.images.sarsonsToBe.portrait |> Array.get 4 of
            Just url ->
                E.image
                    [ E.centerX
                    , E.width (E.maximum maxContentWidth E.fill)
                    , Border.shadow defaultShadow
                    , E.htmlAttribute (Html.Attributes.class "detect-load")
                    ]
                    { src = url
                    , description = "Harry and Sophie, in love."
                    }

            Nothing ->
                E.none
        ]


tab : Model -> { index : Int, name : String, text : String } -> E.Element Msg
tab model page =
    homeOrTab
        []
        [ E.paragraph
            [ E.spacing baseFont
            , E.width (E.maximum maxContentWidth E.fill)
            , E.centerX
            , Region.heading 1
            , Font.size (baseFont * 5 // 2)
            ]
            [ E.text page.name ]
        , E.el
            [ E.width (E.maximum maxContentWidth E.fill)
            , E.padding (padding * 3)
            , E.spacing (padding * 3)
            , E.centerX
            , Border.shadow defaultShadow
            , Background.color colors.white
            , Font.color colors.navy
            ]
            (let
                res =
                    page.text
                        |> Markdown.Parser.parse
                        |> Result.mapError
                            (List.map Markdown.Parser.deadEndToString >> String.join "\n")
                        |> Result.andThen (Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer)
             in
             case res of
                Ok rendered ->
                    E.paragraph
                        [ E.spacing 10
                        , E.padding 10
                        ]
                        (rendered |> List.map E.html)

                Err errors ->
                    E.text errors
            )
        , if model.gui.easter == 3 then
            E.el
                [ E.centerX
                , E.width (maxContentWidth |> E.px)
                ]
                (E.html
                    (Html.iframe
                        [ Html.Attributes.width maxContentWidth
                        , Html.Attributes.id "focus-me"
                        , Html.Attributes.height (maxContentWidth // 2)
                        , Html.Attributes.src "https://harrysarson.github.io/tank/"
                        ]
                        []
                    )
                )

          else
            case model.static.images.sarsonsToBe.landscape |> Array.get page.index of
                Just url ->
                    E.image
                        [ E.centerX
                        , E.width (E.maximum maxContentWidth E.fill)
                        , Border.shadow defaultShadow
                        , E.htmlAttribute (Html.Attributes.class "detect-load")
                        ]
                        { src = url
                        , description = "Harry and Sophie, in love."
                        }

                Nothing ->
                    E.none
        ]


notFound : Model -> E.Element Msg
notFound model =
    E.column
        [ E.width E.fill
        , E.paddingEach
            { bottom = baseFont * 3
            , left = baseFont
            , right = baseFont
            , top = baseFont * 3
            }
        , E.spacing (baseFont * 3)
        ]
        [ E.el
            [ E.spacing baseFont
            , E.width (E.maximum maxContentWidth E.fill)
            , E.centerX
            , Region.heading 1
            , Font.size (baseFont * 3)
            ]
            (E.text "Page not found")
        , case model.static.images.sarsonsToBe.portrait |> Array.get 12 of
            Just url ->
                E.image
                    [ E.centerX
                    , E.width (E.maximum maxContentWidth E.fill)
                    , Border.shadow defaultShadow
                    , E.htmlAttribute (Html.Attributes.class "detect-load")
                    ]
                    { src = url
                    , description = "Harry and Sophie, in love."
                    }

            Nothing ->
                E.none
        , E.el
            [ E.width (E.maximum maxContentWidth E.fill)
            , E.padding (padding * 3)
            , E.spacing (padding * 3)
            , E.centerX
            , Border.shadow defaultShadow
            , Background.color colors.white
            , Font.color colors.navy
            ]
            (E.paragraph
                [ E.spacing 10
                , E.padding 10
                ]
                [ E.text "Sorry, this page does not exist." ]
            )
        ]


body : Model -> Element Msg
body model =
    E.column
        [ E.width E.fill
        , E.height E.fill
        , E.centerX
        , Background.color colors.lightGrey
        , Font.family
            [ Font.typeface "Montserrat"
            , Font.typeface "sans-serif"
            ]
        ]
        [ header model
        , E.el
            [ E.height E.fill
            , E.width E.fill
            , E.scrollbarY
            ]
            (case model.page of
                Home ->
                    home model

                Tab page ->
                    tab model page

                NotFound ->
                    notFound model
            )
        , E.el
            [ E.width E.fill
            , E.height (bannerSize |> E.px)
            ]
            E.none
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Sarson's Wedding"
    , body =
        [ E.layout
            [ Font.family
                [ Font.typeface "Verdana"
                , Font.sansSerif
                ]
            , E.inFront (footer model)
            ]
            (body model)
        ]
    }


navRowFor : String -> Types.Page -> Bool -> Element Msg
navRowFor name onClick borderTop =
    let
        navFontSize =
            baseFont * 3 // 2
    in
    E.el
        (List.concat
            [ [ E.centerX
              , E.height (navFontSize * 5 // 2 |> E.px)
              , E.pointer
              , E.width (E.maximum (navFontSize * 6) E.fill)
              , Events.onClick (ClickedPage onClick)
              ]
            , if borderTop then
                [ Border.widthEach
                    { bottom = 0
                    , left = 0
                    , right = 0
                    , top = 1
                    }
                , Border.color colors.pink
                ]

              else
                []
            ]
        )
        (E.el
            [ E.centerX
            , E.centerY
            , E.spacing 0
            , E.padding (navFontSize * 3 // 4)
            , Font.size navFontSize
            , Font.color colors.pink
            , E.mouseOver
                [ Font.color colors.white ]
            ]
            (E.text name)
        )
