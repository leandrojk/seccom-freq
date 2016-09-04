module Login exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, input, button, h3)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type', class)

import Http
import Task
import Json.Decode as Json


-- MODEL

type alias Model =
  {
  senhaDigitada : String,
  classeDoBotao : String,
  msgResposta : String
  }

init : Model
init =
  Model "" "button is-primary" ""

-- UPDATE

type Msg
  = ArmazeneSenha String
  | EnvieSenha
  | RespostaOk String
  | RespostaErro Http.Error

update : Msg -> Model -> (Model, Cmd Msg)

update msg model =
  case msg of
    ArmazeneSenha senha ->
      ({ model | senhaDigitada = senha }, Cmd.none)

    EnvieSenha ->
      ({ model | classeDoBotao = "button is-primary is-loading" }, enviarSenha model.senhaDigitada)

    RespostaOk resposta ->
      ({model | msgResposta = resposta}, Cmd.none)

    RespostaErro erro ->
      (model, Cmd.none)


enviarSenha : String -> Cmd Msg

enviarSenha senha =
  let
    url = Http.url "WSAutenticador/fazerLogin" [("codigo", senha)]
--    corpo =  Http.multipart [Http.stringData "codigo" senha]
  in
    Task.perform RespostaErro RespostaOk (Http.post decodeMsg url Http.empty )

decodeMsg : Json.Decoder String

decodeMsg =
  Json.at ["Msg"] Json.string

-- VIEW

view : Model -> Html Msg

view model =
  div []
    [ h3 [class "title"] [text "Login"]
    , input [ type' "text", placeholder "Código", onInput ArmazeneSenha ] []
    , button [ class model.classeDoBotao, onClick EnvieSenha ] [text  model.classeDoBotao]
    , h3 [] [text model.msgResposta]
    ]
