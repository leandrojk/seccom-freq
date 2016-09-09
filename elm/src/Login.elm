module Login exposing (Model, Msg, init, update, view, estaLogado)

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

--
--
--

init : Model
init =
  Model "" "button is-primary" False ""

--
--
--
estaLogado : Model -> Bool
estaLogado model =
  model.logado

-- UPDATE

type Msg
  = ArmazeneSenha String
  | EnvieSenha
  | FacaLogout
  | RespostaLoginOk String
  | RespostaErro Http.Error
  | RespostaLogoutOk String

--
--
--
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ArmazeneSenha senha ->
      ({ model | senhaDigitada = senha, aviso = "" }, Cmd.none)

    EnvieSenha ->
      ({ model | classeDoBotao = "button is-primary is-loading" }, enviarSenha model.senhaDigitada)

    RespostaLoginOk resposta ->
      (analisarResposta resposta model, Cmd.none)

    RespostaErro erro ->
      ({model | classeDoBotao = "button is-primary"}, Cmd.none)

    FacaLogout ->
      (model, fazerLogout)

    RespostaLogoutOk resposta ->
      (analisarRespostaLogout resposta model, Cmd.none)

--
--
--
analisarRespostaLogout : String -> Model -> Model
analisarRespostaLogout resposta model =
  let
    logado = False
    cb = "button is-primary"
    aviso = ""
  in
    {model | logado = logado, classeDoBotao = cb, aviso = aviso }

--
--
--
analisarResposta : String -> Model -> Model
analisarResposta resposta model =
  let
    logado = resposta == "LoginAceito"
    cb = "button is-primary"
    aviso = if (logado) then "" else "Código incorreto!"
  in
    {model | logado = logado, classeDoBotao = cb, aviso = aviso }

--
--
--
enviarSenha : String -> Cmd Msg
enviarSenha senha =
  let
    url = Http.url "WSAutenticador/fazerLogin" [("codigo", senha)]
  in
    Task.perform RespostaErro RespostaLoginOk (Http.post decodeMsg url Http.empty )


--
--
--
decodeMsg : Json.Decoder String
decodeMsg =
  Json.at ["Msg"] Json.string


--
--
--
fazerLogout : Cmd Msg
fazerLogout =
  let
    url = Http.url "WSAutenticador/fazerLogout" []
  in
    Task.perform RespostaErro RespostaLogoutOk (Http.post decodeMsg url Http.empty)


--
-- VIEW
--
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
