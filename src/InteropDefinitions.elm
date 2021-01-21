module InteropDefinitions exposing (Flags, FromElm(..), ToElm, interop)

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import TsInterop.Decode as Decode exposing (Decoder)
import TsInterop.Encode as Encoder exposing (Encoder, optional, required)


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


type alias Flags =
    { pages : Array { name : String, text : String }
    , images :
        { invite : String
        , sarsonsToBe : Array String
        }
    }


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
    Decode.map2
        (\pages images_ ->
            { pages = pages, images = images_ }
        )
        (Decode.field "pages" (Decode.array page))
        (Decode.field "images" images)


page : Decode.Decoder { name : String, text : String }
page =
    Decode.map2
        (\name text ->
            { name = name, text = text }
        )
        (Decode.field "name" Decode.string)
        (Decode.field "text" Decode.string)


images : Decode.Decoder { invite : String, sarsonsToBe : Array String }
images =
    Decode.map2
        (\invite sarsonsToBe ->
            { invite = invite, sarsonsToBe = sarsonsToBe }
        )
        (Decode.field "invite" Decode.string)
        (Decode.field "sarsonsToBe" (Decode.array Decode.string))
