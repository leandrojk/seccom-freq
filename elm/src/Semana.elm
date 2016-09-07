module Semana exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, button, input, table, tbody, th, tr, td, span)
import Html.Attributes exposing (class, type', placeholder, value)
import Html.Events exposing (onClick, onInput)

import Http
import Task
import Json.Decode as Json exposing((:=))

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
      let
        semanas = []
        mensagem = "Buscando semanas..."
      in
        ({model | semanas = semanas, mensagem = mensagem}, buscarSemanas)

    Erro e ->
      (model, Cmd.none)

    RespostaTodas semanas ->
      let
        mensagem = ""
      in
        ({model | semanas = semanas, mensagem = mensagem}, Cmd.none)

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
      let
        mensagem = "Cadastrando semana..."
      in
        ({model | mensagem = mensagem}, cadastrarSemana model.novaSemana)

    RespostaCadastrar msg ->
      let
        semanasAtualizada = model.novaSemana :: model.semanas
        mensagem = ""
      in
        ({model | semanas = semanasAtualizada, novaSemana = {ano = 0, nome = "", tema = ""}, mensagem = mensagem},Cmd.none)


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
  Json.object3 Semana ("ano" := Json.int) ("nome" := Json.string) ("tema" := Json.string)


-- VIEW
view : Model -> Html Msg
view model =
  div
    [class "box"]
    [
    div [class "title"] [text "Semana"]
    , mostrarMensagem model.mensagem
    , button [class "button is-primary", onClick BusqueSemanas] [text "Mostrar Todas"]
    , mostrarSemanas model.semanas
    , formSemana model.novaSemana
    ]

mostrarMensagem : String -> Html Msg
mostrarMensagem texto =
  if String.length texto == 0 then div [][]
    else div [class "notification is-info"] [text texto]

mostrarSemanas : List Semana -> Html Msg
mostrarSemanas semanas =
  let
    linhas = List.map (\semana -> tr [] [td [] [text (toString semana.ano)], td [] [text semana.nome], td [] [text semana.tema]]) semanas
  in
  div [class "box"]
    [table []
      [ tr [] [th [] [text "Ano"], th [] [text "Nome"], th [] [text "Tema"]]
      , tbody [] linhas
      ]
    ]


formSemana : Semana -> Html Msg
formSemana novaSemana =
  div []
  [ span [] [text "Ano : "], input [type' "number", placeholder "ano", onInput ArmazeneAno, value (toString novaSemana.ano)] []
  , span [] [text "Nome : "], input [type' "text", placeholder "nome", onInput ArmazeneNome, value novaSemana.nome] []
  , span [] [text "Tema : "], input [type' "text", placeholder "tema", onInput ArmazeneTema, value novaSemana.tema] []
  , button [class "button is-primary", onClick  CadastreSemana] [text "Cadastrar"]
  ]
