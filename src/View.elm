module View exposing (view)

import Array
import Browser
import Dict
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Route exposing (Page)
import Types exposing (..)


padding : Int
padding =
    4


baseFont : Int
baseFont =
    18


bannerSize =
    baseFont * 5


colors =
    { navy = E.rgb255 0x0D 0x16 0x2D
    , white = E.rgb 1 1 1
    , black = E.rgb 0 0 0
    , grey = E.rgb 0.6 0.6 0.6
    , lightGrey = E.rgb 0.95 0.95 0.95
    , pink = E.rgb255 245 169 173
    , washedoutPink = E.rgb255 0xF6 0xE7 0xC9
    }


defaultShadow =
    { offset = ( 0, 1 )
    , size = toFloat padding
    , blur = toFloat padding
    , color = E.rgba 0 0 0 0.1
    }


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
        navs =
            ("home"
                :: (model.static.pages
                        |> Dict.keys
                   )
            )
                |> List.map String.toUpper
    in
    case (E.classifyDevice model.dims).orientation of
        E.Landscape ->
            E.row
                [ E.width E.fill
                , E.explain Debug.todo
                , Region.navigation
                ]
                (navs
                    |> List.map
                        (\name ->
                            E.el
                                [ E.width E.fill
                                , E.padding padding
                                ]
                                (E.text name)
                        )
                )

        E.Portrait ->
            let
                buttonSize =
                    baseFont * 4

                fontSize =
                    baseFont * 3

                dropDown =
                    [ E.below
                        (E.column
                            [ E.width E.fill
                            , Region.navigation
                            , Background.color colors.navy
                            , Font.color colors.white
                            ]
                            (navRowFor "HOME" Home False
                                :: (model.static.pages
                                        |> Dict.toList
                                        |> List.indexedMap
                                            (\index ( name, { text } ) ->
                                                navRowFor (String.toUpper name)
                                                    (Tab
                                                        { index = index + 1
                                                        , name = name
                                                        , text = text
                                                        }
                                                    )
                                                    True
                                            )
                                   )
                            )
                        )
                    ]
            in
            bannerBar
                (if model.gui.navDropDown then
                    dropDown

                 else
                    []
                )
                (E.paragraph
                    [ E.centerX
                    , E.centerY
                    , E.height (buttonSize |> E.px)
                    , E.width (buttonSize |> E.px)
                    , E.spacing (fontSize - buttonSize)
                    , E.pointer
                    , E.htmlAttribute (Html.Attributes.attribute "style" "user-select:none")
                    , Background.color colors.white
                    , Border.rounded padding
                    , Font.size fontSize
                    , Font.color colors.grey
                    , E.mouseOver
                        [ Font.color colors.pink ]
                    , Events.onClick ToggleNavDropDown
                    ]
                    [ E.text "≡" ]
                )


footer : Model -> Element Msg
footer model =
    let
        buttonSize =
            baseFont * 4

        fontSize =
            baseFont * 3
    in
    bannerBar
        []
        (E.link
            [ E.centerX
            , E.centerY
            , Font.size (baseFont * 2)
            , Font.color colors.lightGrey
            , E.pointer
            , E.mouseOver
                [ Font.color colors.pink ]
            ]
            { url = model.static.rsvpUrl, label = E.text "Please RSVP" }
        )


home : Element Msg
home =
    let
        nameAttrs =
            [ E.centerX
            , Font.size (baseFont * 3)
            ]
    in
    E.column
        [ E.width E.fill
        , E.padding (baseFont * 5)
        , E.spacing (baseFont * 3)
        ]
        [ E.column
            [ E.centerX
            , E.spacing baseFont
            ]
            [ E.el nameAttrs (E.text "Harry Sarson")
            , E.el [ E.centerX ] (E.text "AND")
            , E.el nameAttrs (E.text "Sophie Burke")
            ]
        , E.el
            [ E.centerX
            , Font.size (baseFont * 2)
            ]
            (E.text "5th June 2021")
        , E.el
            [ E.width E.fill
            , E.padding (padding * 3)
            , E.spacing (padding * 3)
            , Border.shadow defaultShadow
            , Background.color colors.navy
            , Font.color colors.white
            ]
            (E.textColumn
                []
                [ E.el
                    [ Region.heading 2
                    , Font.size (baseFont * 2)
                    ]
                    (E.text "Schedule")
                , E.paragraph [ Font.size (baseFont * 2) ] [ E.text "- first thing" ]
                ]
            )
        ]


tab : Model -> { index : Int, name : String, text : String } -> E.Element Msg
tab model page =
    let
        nameAttrs =
            [ E.centerX
            , Font.size (baseFont * 3)
            ]
    in
    E.column
        [ E.width E.fill
        , E.padding (baseFont * 5)
        , E.spacing (baseFont * 3)
        ]
        [ E.el
            [ E.centerX
            , E.spacing baseFont
            , Region.heading 1
            , Font.size (baseFont * 3)
            ]
            (E.text page.name)
        , case model.static.images.sarsonsToBe.portrait |> Array.get page.index of
            Just url ->
                E.image
                    [ E.centerX
                    , E.width (baseFont * 20 |> E.px)
                    , Border.shadow defaultShadow
                    , E.htmlAttribute (Html.Attributes.class "detect-load")
                    ]
                    { src = url
                    , description = "Harry and Sophie, in love."
                    }

            Nothing ->
                E.none
        , E.el
            [ E.width E.fill
            , E.padding (padding * 3)
            , E.spacing (padding * 3)
            , Border.shadow defaultShadow
            , Background.color colors.white
            , Font.color colors.black
            ]
            (let
                res =
                    page.text
                        |> Markdown.Parser.parse
                        |> Result.mapError (\error -> error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")
                        |> Result.andThen (Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer)
             in
             case res of
                Ok rendered ->
                    E.paragraph
                        [ E.spacing 30
                        , E.padding 50
                        ]
                        (rendered |> List.map E.html)

                Err errors ->
                    E.text errors
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
            [ Font.typeface "PT Serif"
            , Font.serif
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
                    home

                Tab page ->
                    tab model page

                NotFound ->
                    E.text "sorry we cannot find that page"
            )
        , footer model
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Welsh Whacker"
    , body =
        [ E.layout
            ([ Just
                (Font.family
                    [ Font.typeface "Verdana"
                    , Font.sansSerif
                    ]
                )
             ]
                |> List.filterMap identity
            )
            (body model)
        ]
    }


navRowFor : String -> Types.Page -> Bool -> Element Msg
navRowFor name onClick borderTop =
    E.el
        (List.concat
            [ [ E.centerX
              , E.height (baseFont * 5 // 2 |> E.px)
              , E.pointer
              , E.mouseOver
                    [ Font.color colors.pink ]
              , E.width (baseFont * 6 |> E.px)
              , Events.onClick (ClickedPage onClick)
              ]
            , if borderTop then
                [ Border.widthEach
                    { bottom = 0
                    , left = 0
                    , right = 0
                    , top = 1
                    }
                , Border.color colors.white
                ]

              else
                []
            ]
        )
        (E.el
            [ E.centerX
            , E.centerY
            , E.spacing 0
            , Font.size baseFont
            , E.padding (baseFont * 3 // 4)
            ]
            (E.text name)
        )