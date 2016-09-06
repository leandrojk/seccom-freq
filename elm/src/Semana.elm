module Semana exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

import Http
import Task
import Json.Decode as Json

-- MODEL

type alias Model =
  {
    semanas : List Semana
  }

type alias Semana =
  {
    ano : Int,
    nome : String,
    tema : String
  }

init : Model
init =
  Model []

-- UPDATE

type Msg =
  BusqueSemanas
  | Erro Http.Error
  | RespostaTodas String -- na verdade List Semana

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    BusqueSemanas ->
      (model, buscarSemanas)

    Erro e ->
      (model, Cmd.none)

    RespostaTodas r ->
      (model, Cmd.none)

buscarSemanas : Cmd Msg
buscarSemanas =
  let
    url = "WSSemana/encontrarTodas"
  in
    Task.perform Erro RespostaTodas (Http.get decoderTodas url)

decoderTodas : Json.Decoder String
decoderTodas =
  Json.at ["Msg"] Json.string

-- VIEW
view : Model -> Html Msg
view model =
  div
    [class "box"]
    [
    div [class "title"] [text "Semana"]
    , button [class "button is-primary", onClick BusqueSemanas] [text "Mostrar Todas"]
    ]
