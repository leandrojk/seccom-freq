module Palestra exposing (Model, Msg, Palestra, init, update, view, decoderTodas)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

import Json.Decode as Json exposing((:=))


-- MODEL

type alias Model =
  {

  }

type alias Palestra =
  { id : Int
  , semanaAno : Int
  , titulo : String
  , palestrante : String
  , dia : String
  , horarioDeInicio : String
  , horarioDeTermino : String
  }


init : Model
init =
  Model

-- UPDATE

type Msg = A

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

decoderTodas : Json.Decoder (List Palestra)
decoderTodas =
  Json.at ["palestras"] (Json.list decoderPalestra)

decoderPalestra : Json.Decoder Palestra
decoderPalestra =
  Json.object7 Palestra
               ("id" := Json.int)
               ("semanaAno" := Json.int)
               ("titulo" := Json.string)
               ("palestrante" := Json.string)
               ("dia" := Json.string)
               ("horarioDeInicio" := Json.string)
               ("horarioDeTermino" := Json.string)



-- VIEW
view : Model -> Html Msg
view model =
  div [class "box"] [text "a palestra..."]
