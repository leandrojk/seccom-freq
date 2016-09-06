module Semana exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, button, input)
import Html.Attributes exposing (class, type', placeholder)
import Html.Events exposing (onClick, onInput)

import Http
import Task
import Json.Decode as Json exposing(..)

import String


-- MODEL

type alias Model =
  {
    semanas : List Semana,
    novaSemana : Semana,
    mensagem : String
  }

type alias Semana =
  {
    ano : Int,
    nome : String,
    tema : String
  }

init : Model
init =
  Model [] {ano = 0, nome = "", tema = ""} ""

-- UPDATE

type Msg =
  BusqueSemanas
  | Erro Http.Error
  | RespostaTodas (List Semana)
  | ArmazeneAno String
  | ArmazeneNome String
  | ArmazeneTema String
  | CadastreSemana
  | RespostaCadastrar String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    BusqueSemanas ->
      (model, buscarSemanas)

    Erro e ->
      (model, Cmd.none)

    RespostaTodas semanas ->
      ({model | semanas = semanas}, Cmd.none)

    ArmazeneAno sAno ->
      let
        ano = Result.withDefault 0 (String.toInt sAno)
        novaSemana = {ano = ano, nome = model.novaSemana.nome, tema = model.novaSemana.tema}
      in
      ({model | novaSemana = novaSemana}, Cmd.none)

    ArmazeneNome nome ->
      let
        novaSemana = {ano = model.novaSemana.ano, nome = nome, tema = model.novaSemana.tema}
      in
      ({model | novaSemana = novaSemana}, Cmd.none)

    ArmazeneTema tema ->
      let
        novaSemana = {ano = model.novaSemana.ano, nome = model.novaSemana.nome, tema = tema}
      in
      ({model | novaSemana = novaSemana}, Cmd.none)

    CadastreSemana ->
        (model, cadastrarSemana model.novaSemana)

    RespostaCadastrar msg ->
      let
        semanasAtualizada = model.novaSemana :: model.semanas
      in
        ({model | semanas = semanasAtualizada, novaSemana = {ano = 0, nome = "", tema = ""}},Cmd.none)


buscarSemanas : Cmd Msg
buscarSemanas =
  let
    url = "WSSemana/encontrarTodas"
  in
    Task.perform Erro RespostaTodas (Http.get decoderTodas url)


cadastrarSemana : Semana -> Cmd Msg
cadastrarSemana semana =
  let
    url = Http.url "WSSemana/cadastrar" [("ano", (toString semana.ano)), ("nome", semana.nome), ("tema", semana.tema)]
  in
    Task.perform Erro RespostaCadastrar (Http.post ("Msg" := Json.string) url Http.empty)

decoderTodas : Json.Decoder (List Semana)
decoderTodas =
  Json.at ["semanas"] (Json.list decoderSemana)

decoderSemana : Json.Decoder Semana
decoderSemana =
  object3 Semana ("ano" := Json.int) ("nome" := Json.string) ("tema" := Json.string)


-- VIEW
view : Model -> Html Msg
view model =
  div
    [class "box"]
    [
    div [class "title"] [text "Semana"]
    , button [class "button is-primary", onClick BusqueSemanas] [text "Mostrar Todas"]
    , mostrarSemanas model.semanas
    , formSemana
    ]

mostrarSemanas : List Semana -> Html Msg
mostrarSemanas semanas =
  div [class "box"] (List.map (\semana -> div [] [text ((toString semana.ano)  ++ " - " ++ semana.nome ++ " - " ++ semana.tema)]) semanas)

formSemana : Html Msg
formSemana =
  div []
  [ input [type' "number", placeholder "ano", onInput ArmazeneAno] []
  , input [type' "text", placeholder "nome", onInput ArmazeneNome] []
  , input [type' "text", placeholder "tema", onInput ArmazeneTema] []
  , button [class "button is-primary", onClick  CadastreSemana] [text "Cadastrar"]
  ]
