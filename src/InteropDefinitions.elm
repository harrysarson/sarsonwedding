module InteropDefinitions exposing (FromElm(..), ToElm, interop)

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import TsInterop.Decode as Decode exposing (Decoder)
import TsInterop.Encode as Encoder exposing (Encoder, optional, required)
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
    Decode.map3
        (\pages images_ rsvpUrl ->
            { pages = pages, images = images_, rsvpUrl = rsvpUrl }
        )
        (Decode.field "pages" (Decode.dict page))
        (Decode.field "images" images)
        (Decode.field "rsvpUrl" Decode.string)


page : Decode.Decoder { text : String }
page =
    Decode.map
        {- 2 -}
        (\{- name -} text ->
            { {- name = name, -} text = text }
        )
        {- (Decode.field "name" Decode.string) -} (Decode.field "text" Decode.string)


images :
    Decode.Decoder
        { invite : String
        , sarsonsToBe :
            { portrait : Array String
            , landscape : Array String
            }
        }
images =
    Decode.map2
        (\invite sarsonsToBe ->
            { invite = invite
            , sarsonsToBe = sarsonsToBe
            }
        )
        (Decode.field "invite" Decode.string)
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
