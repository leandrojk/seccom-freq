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
  loginDigitado : Maybe String,
  senhaDigitada : Maybe String,
  classeDoBotao : String,
  aviso : Maybe String,
  usuario : Maybe Usuario
  }

--
--
--

init : Model
init =
  Model Nothing Nothing "button is-primary" Nothing Nothing

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
      ({ model | senhaDigitada = Just senha, aviso = Nothing }, Cmd.none)

    ArmazeneLogin login ->
      ({ model | loginDigitado = Just login, aviso = Nothing }, Cmd.none)

    FazerLogin ->
      case (model.loginDigitado, model.senhaDigitada) of
        (Just login, Just senha) ->
          ({ model | classeDoBotao = "button is-primary is-loading" }, fazerLogin login senha)

        _ -> (model, Cmd.none)

    RespostaLoginOk mbUsuario ->
      (analisarRespostaLogin mbUsuario model, Cmd.none)

    RespostaErro erro ->
      let
        aviso = Just "Erro na resposta http"
      in
        ({model | aviso = aviso, classeDoBotao = "button is-primary"}, Cmd.none)

    FacaLogout ->
      (model, fazerLogout)

    RespostaLogoutOk resposta ->
      (init, Cmd.none)


--
--
--
analisarRespostaLogin : Maybe Usuario -> Model -> Model
analisarRespostaLogin mbUsuario model =
  case mbUsuario of
    Nothing ->
      let
        cb = "button is-primary"
        aviso = Just "Login e/ou senha incorretos!"
      in
        {model | classeDoBotao = cb, aviso = aviso }

    Just usuario ->
      let
        cb = "button is-primary"
        aviso = Nothing
      in
          {model | classeDoBotao = cb, aviso = aviso, usuario = mbUsuario}

--
--
--
fazerLogin : String -> String -> Cmd Msg
fazerLogin login senha =
  let
    url = Http.url "WSAutenticador/fazerLogin" []
    corpo = Http.string ("login=" ++ login ++ "&senha=" ++ senha)
  in
    Task.perform RespostaErro RespostaLoginOk (HttpUtil.post' decodeRespostaLogin url corpo)


--
--
--
decodeRespostaLogin : Json.Decoder (Maybe Usuario)
decodeRespostaLogin =
  ("Msg" := Json.string) `Json.andThen` decodeMaybeUsuario

decodeMaybeUsuario : String -> Json.Decoder (Maybe Usuario)
decodeMaybeUsuario msg =
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
        , mostreAviso model.aviso
        ]

mostreAviso : Maybe String -> Html Msg
mostreAviso mbAviso =
  case mbAviso of
    Nothing -> div [] []
    Just msg -> div [class "is-info"] [text msg]
