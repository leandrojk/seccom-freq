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
  logado : Bool,
  aviso : String
  }

init : Model
init =
  Model "" "button is-primary" False ""

-- UPDATE

type Msg
  = ArmazeneSenha String
  | EnvieSenha
  | FacaLogout
  | RespostaOk String
  | RespostaErro Http.Error
  | RespostaLogoutOk String

update : Msg -> Model -> (Model, Cmd Msg)

update msg model =
  case msg of
    ArmazeneSenha senha ->
      ({ model | senhaDigitada = senha }, Cmd.none)

    EnvieSenha ->
      ({ model | classeDoBotao = "button is-primary is-loading" }, enviarSenha model.senhaDigitada)

    RespostaOk resposta ->
      (analisarResposta resposta model, Cmd.none)

    RespostaErro erro ->
      ({model | classeDoBotao = "button is-primary"}, Cmd.none)

    FacaLogout ->
      (model, fazerLogout)

    RespostaLogoutOk resposta ->
      (analisarRespostaLogout resposta model, Cmd.none)


analisarResposta : String -> Model -> Model
analisarResposta resposta model =
  let
    logado = resposta == "LoginAceito"
    cb = "button is-primary"
    aviso = if (logado) then "" else "Código incorreto!"
  in
    {model | logado = logado, classeDoBotao = cb, aviso = aviso }

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


fazerLogout : Cmd Msg

fazerLogout =
  let
    url = Http.url "WSAutenticador/fazerLogout"
  in
    Task.perform RespostaErro RespostaLogoutOk (Http.post decodeMsg url Http.empty )
-- VIEW

view : Model -> Html Msg

view model =
  case model.logado of
    True -> div []
      [
      h3 [class "title"] [text "Logout"]
      , button [class model.classeDoBotao, onClick FacaLogout] [text "Sair"]
      ]

    False -> div []
        [ h3 [class "title"] [text "Login"]
        , input [ type' "text", placeholder "Código", onInput ArmazeneSenha ] []
        , button [ class model.classeDoBotao, onClick EnvieSenha ] [text  "Entrar"]
        , h3 [] [text model.aviso]
        ]
