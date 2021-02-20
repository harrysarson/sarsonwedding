module InteropDefinitions exposing (FromElm(..), ToElm, interop)

import Array exposing (Array)
import TsJson.Decode as Decode exposing (Decoder)
import TsJson.Encode as Encoder exposing (Encoder, required)
import Types exposing (Flags)


interop : { toElm : Decoder ToElm, fromElm : Encoder FromElm, flags : Decode.Decoder Flags }
interop =
    { toElm = Decode.null ()
    , fromElm = fromElm
    , flags = flags
    }


type FromElm
    = SendPresenceHeartbeat
    | Alert String


type alias ToElm =
    ()


fromElm : Encoder.Encoder FromElm
fromElm =
    Encoder.union
        (\vSendHeartbeat vAlert value ->
            case value of
                SendPresenceHeartbeat ->
                    vSendHeartbeat

                Alert string ->
                    vAlert string
        )
        |> Encoder.variant0 "SendPresenceHeartbeat"
        |> Encoder.variantObject "Alert" [ required "message" identity Encoder.string ]
        |> Encoder.buildUnion


flags : Decode.Decoder Flags
flags =
    Decode.map4
        (\pages images_ rsvpUrl schedule ->
            { pages = pages, images = images_, rsvpUrl = rsvpUrl, schedule = schedule }
        )
        (Decode.field "pages" (Decode.dict page))
        (Decode.field "images" images)
        (Decode.field "rsvpUrl" Decode.string)
        (Decode.field "schedule" (Decode.list scheduleRow))


page : Decode.Decoder { text : String }
page =
    Decode.map
        (\text -> { text = text })
        (Decode.field "text" Decode.string)


scheduleRow : Decode.Decoder { time : String, text : String }
scheduleRow =
    Decode.map2
        (\time text ->
            { time = time, text = text }
        )
        (Decode.field "time" Decode.string)
        (Decode.field "text" Decode.string)


images :
    Decode.Decoder
        { invite : String
        , flower : { top : String, bottom : String }
        , sarsonsToBe :
            { portrait : Array String
            , landscape : Array String
            }
        }
images =
    Decode.map3
        (\invite flower_ sarsonsToBe ->
            { invite = invite
            , flower = flower_
            , sarsonsToBe = sarsonsToBe
            }
        )
        (Decode.field "invite" Decode.string)
        (Decode.field "flower" flower)
        (Decode.field "sarsonsToBe"
            (Decode.map2
                (\portrait landscape ->
                    { portrait = portrait
                    , landscape = landscape
                    }
                )
                (Decode.field "portrait" (Decode.array Decode.string))
                (Decode.field "landscape" (Decode.array Decode.string))
            )
        )


flower :
    Decode.Decoder
        { top : String, bottom : String }
flower =
    Decode.map2
        (\top bottom ->
            { top = top
            , bottom = bottom
            }
        )
        (Decode.field "top" Decode.string)
        (Decode.field "bottom" Decode.string)
