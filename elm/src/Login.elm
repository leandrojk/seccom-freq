module Login exposing (Model, Msg, init, update, view, estaLogado)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type', class)

import Http
import Task
import Json.Decode as Json exposing ((:=))
import HttpUtil

-- MODEL

type alias Usuario = {
  login : String,
  nome : String,
  adm : Bool
}

type alias Model =
  {
  loginDigitado : String,
  senhaDigitada : String,
  classeDoBotao : String,
  aviso : String,
  usuario : Maybe Usuario
  }

--
--
--

init : Model
init =
  Model "" "" "button is-primary" "" Nothing

--
--
--
estaLogado : Model -> Bool
estaLogado model =
  case model.usuario of
    Nothing -> False

    Just _ -> True

-- UPDATE

type Msg
  = ArmazeneSenha String
  | ArmazeneLogin String
  | FazerLogin
  | FacaLogout
  | RespostaLoginOk (Maybe Usuario)
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

    ArmazeneLogin login ->
      ({ model | loginDigitado = login, aviso = "" }, Cmd.none)

    FazerLogin ->
      ({ model | classeDoBotao = "button is-primary is-loading" }, fazerLogin model.loginDigitado model.senhaDigitada)

    RespostaLoginOk mbUsuario ->
      (analisarResposta mbUsuario model, Cmd.none)

    RespostaErro erro ->
      let
        aviso = "Erro na resposta http"
      in
        ({model | aviso = aviso, classeDoBotao = "button is-primary"}, Cmd.none)

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
    cb = "button is-primary"
    aviso = ""
  in
    {model | usuario = Nothing, classeDoBotao = cb, aviso = aviso }

--
--
--
analisarResposta : Maybe Usuario -> Model -> Model
analisarResposta resposta model =
  case resposta of
    Nothing ->
      let
        cb = "button is-primary"
        aviso = "Login e/ou senha incorretos!"
      in
        {model | classeDoBotao = cb, aviso = aviso }

    Just usuario ->
      let
        cb = "button is-primary"
        aviso = ""
      in
          {model | classeDoBotao = cb, aviso = aviso, usuario = resposta}

--
--
--
fazerLogin : String -> String -> Cmd Msg
fazerLogin login senha =
  let
    url = Http.url "WSAutenticador/fazerLogin" []
    corpo = Http.string ("login=" ++ login ++ "&senha=" ++ senha)
  in
    Task.perform RespostaErro RespostaLoginOk (HttpUtil.post' decodeMsg url corpo)


--
--
--
decodeMsg : Json.Decoder (Maybe Usuario)
decodeMsg =
  ("Msg" := Json.string) `Json.andThen` decode2

decode2 : String -> Json.Decoder (Maybe Usuario)
decode2 msg =
  case msg of
    "LoginAceito" ->
      Json.maybe ("usuario" := Json.object3 Usuario ("login" := Json.string) ("nome" := Json.string) ("adm" := Json.bool))

    _ -> Json.maybe (Json.fail "login e/ou senha incorretos")

--
--
--
fazerLogout : Cmd Msg
fazerLogout =
  let
    url = Http.url "WSAutenticador/fazerLogout" []
  in
    Task.perform RespostaErro RespostaLogoutOk (Http.post ("Msg" := Json.string) url Http.empty)


--
-- VIEW
--
view : Model -> Html Msg
view model =
  case model.usuario of
    Just usuario -> div []
      [ h4 [class "subtitle"] [text usuario.nome]
      , button [class model.classeDoBotao, onClick FacaLogout] [text "Sair"]
      ]

    Nothing -> div []
        [ h3 [class "title"] [text "Login"]
        , span [] [text "Login : "]
        , input [type' "text", placeholder "login", onInput ArmazeneLogin ] []
        , br [] []
        , span [] [text "Senha : "]
        , input [ type' "password", placeholder "senha", onInput ArmazeneSenha ] []
        , br [] []
        , button [ class model.classeDoBotao, onClick FazerLogin ] [text  "Entrar"]
        , h3 [] [text model.aviso]
        ]
