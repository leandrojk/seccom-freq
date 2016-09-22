module Presenca exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Html.App as App

import Http
import Task
import Json.Decode as Json exposing((:=))

import String

import Estudante exposing (Estudante)
import Palestra exposing (Palestra)
import EscolherPalestra
import HttpUtil

-- MODEL

type alias Model =
  {
    palestra : EscolherPalestra.Model,
    estudante : Maybe Estudante,
    matricula : Maybe Int,
    mensagem : Maybe Mensagem,
    ativo : Bool,
    expirou : Bool -- só será True quando sessão expirar no servidor
  }

type alias Mensagem =
  { msg : String
  , tipo : String  -- tipos válidos para o CSS Bulma
  }

init : Model
init =
  Model EscolherPalestra.init Nothing Nothing Nothing True False


-- UPDATE

type Msg =
  Ativar
  | Desativar
  | MsgEscolherPalestra EscolherPalestra.Msg
  | Matricula String
  | HttpErro Http.Error
  | PesquiseEstudante
  | HttpRespostaPesquisarEstudante (Maybe (Maybe Estudante))
  | RegistrePresenca Int Int
  | HttpRespostaRegistrarPresenca (Maybe Bool)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Ativar ->
      (init, Cmd.none)

    Desativar ->
      ({init | ativo = False}, Cmd.none)

    MsgEscolherPalestra msg ->
      let
        (palestra, comando) = EscolherPalestra.update msg model.palestra
      in
        case palestra.expirou of
          True -> sessaoExpirada

          False ->
            ({model | palestra = palestra, mensagem = Nothing}, Cmd.map MsgEscolherPalestra comando)


    Matricula sMatricula ->
      case String.toInt sMatricula of
        Ok matricula ->
          ({model | matricula = Just matricula, mensagem = Nothing, estudante = Nothing}, Cmd.none)

        Err _ ->
          let
            mensagem = Just (Mensagem "Digite apenas números" "is-danger")
          in
            ({model | matricula = Nothing, estudante = Nothing, mensagem = mensagem}, Cmd.none)



    PesquiseEstudante ->
      case model.matricula of
        Nothing -> ({model | mensagem = Just (Mensagem "Matrícula não definida" "is-warning")}, Cmd.none)

        Just matricula ->
          let
            msg = Just (Mensagem "Buscando estudante..." "is-info")
          in
            ({model | mensagem = msg}, pesquisarEstudante matricula)

    HttpErro erro ->
      let
        msg = Just (Mensagem (toString erro) "is-danger")
      in
       ({model | mensagem = msg}, Cmd.none)


    HttpRespostaPesquisarEstudante maybeMaybeEstudante ->
      case maybeMaybeEstudante of
        Nothing -> sessaoExpirada

        Just maybeEstudante ->
          case maybeEstudante of
            Nothing ->
              ({model | mensagem = Just (Mensagem "Estudante não cadastrado!" "is-warning")}, Cmd.none)

            Just estudante ->
              ({model | estudante = maybeEstudante, mensagem = Nothing}, Cmd.none)


    RegistrePresenca idPalestra matricula->
      let
        sm = toString matricula
        sid = toString idPalestra
        url = Http.url "WSPresenca/cadastrar" []
        corpo = Http.string ("matricula=" ++ sm ++ "&palestra=" ++ sid)
        comando = Task.perform HttpErro HttpRespostaRegistrarPresenca (HttpUtil.post' decoderRespostaRegistrarPresenca url corpo)
      in
        ({model | mensagem = Just (Mensagem "registrando..." "is-info")}, comando)

    HttpRespostaRegistrarPresenca mbRegistrou ->
      case mbRegistrou of
          Nothing -> sessaoExpirada

          Just registrou ->
            let
              mensagem = case registrou of
                True -> Just (Mensagem "Presença registrada com sucesso" "is-success")
                False -> Just (Mensagem "Presença já havia sido registrada" "is-warning")
            in
              ({model | mensagem = mensagem}, Cmd.none)


sessaoExpirada : (Model, Cmd Msg)
sessaoExpirada =
  let
    mensagem = Just (Mensagem "Sessão expirada! Saia e entre novamente" "is-danger")
  in
    ({init | mensagem = mensagem, expirou = True}, Cmd.none)

--
--




pesquisarEstudante : Int -> Cmd Msg
pesquisarEstudante matricula =
  let
    url = Http.url "WSEstudante/encontrarPorMatricula" [("matricula", toString(matricula))]
  in
    Task.perform HttpErro HttpRespostaPesquisarEstudante (Http.get decoderMsgEstudante url)



decoderMsgEstudante : Json.Decoder (Maybe (Maybe Estudante))
decoderMsgEstudante =
  ("Msg" := Json.string) `Json.andThen` dme

dme : String -> Json.Decoder (Maybe (Maybe Estudante))
dme msg =
  case msg of
    "EstudanteNaoEncontrado" -> Json.succeed (Just Nothing)

    "EstudanteEncontrado" ->
       Json.maybe (Json.maybe (Estudante.decoderEstudante))

    "UsuarioNaoLogado" -> Json.maybe(Json.fail "sessão expirada")

    _ -> Json.maybe(Json.fail "parâmetro Msg não reconhecido")

decoderRespostaRegistrarPresenca : Json.Decoder (Maybe Bool)
decoderRespostaRegistrarPresenca =
  ("Msg" := Json.string) `Json.andThen` drrp

drrp : String -> Json.Decoder (Maybe Bool)
drrp msg =
  case msg of
    "PresencaCadastrada" -> Json.succeed (Just True)
    "PresencaJaCadastrada" -> Json.succeed (Just False)
    "UsuarioNaoLogado" -> Json.maybe (Json.fail "sessão expirada")
    _ -> Json.maybe (Json.fail "resposta inválida vinda do servidor")




-- VIEW
view : Model -> Html Msg
view model =
  case model.expirou of
    True ->  mostrarMensagem model.mensagem

    False -> view2 model

view2 : Model -> Html Msg
view2 model =
  case model.ativo of
    False ->
      div []
        [ button [class "tag is-primary", onClick Ativar]
                 [text "Registrar Presença"]
        ]

    True ->
      div [class "box"]
        [ button [class "tag is-info", onClick Desativar] [text "Fechar"]
        , div [class "title"] [text "Registrar Presença"]
        , App.map MsgEscolherPalestra (EscolherPalestra.view model.palestra)
        , escolherAluno (EscolherPalestra.palestraEscolhida model.palestra) model.matricula
        , registrarPresenca (EscolherPalestra.palestraEscolhida model.palestra, model.estudante)
        , mostrarMensagem model.mensagem
        ]


escolherAluno : Maybe Palestra -> Maybe Int -> Html Msg
escolherAluno mbPalestra mbMatricula =
  case mbPalestra of
    Nothing -> div [] []

    Just _ ->
      div
       [ class "box" ]
       [ div [class "title"] [text "Definir Estudante"]
       , span [] [text "Matrícula : "]
       , input [type' "number", onInput Matricula] []
       , mostrarBotaoPesquisarEstudante mbMatricula
       ]

mostrarBotaoPesquisarEstudante : Maybe Int -> Html Msg
mostrarBotaoPesquisarEstudante mbMatricula =
  case mbMatricula of
    Nothing -> div [] []

    Just _ ->
       button
        [class "button is-primary", onClick PesquiseEstudante]
        [text "Buscar Estudante"]


registrarPresenca : (Maybe Palestra, Maybe Estudante) -> Html Msg
registrarPresenca (mbPalestra, mbEstudante) =
  case (mbPalestra, mbEstudante) of
    (Just palestra, Just estudante) ->
      let
        mostrarPalestra = \palestra ->
          div []
            [ span [class "subtitle"] [text "Palestra : "]
            , br [] []
            , p []
                [ text palestra.dia
                , text " - "
                , text palestra.horarioDeInicio
                , text "  "
                , text palestra.titulo
                , text " - "
                , text palestra.palestrante
                ]
            ]
      in
        div [class "box"]
          [ div [class "title"] [text "Registrar Presença"]
          , mostrarPalestra palestra
          , hr [] []
          , span [class "subtitle"] [text "Estudante : "]
          , br [] []
          , p [] [text (toString estudante.matricula), text " -- ", text estudante.nome]
          , br [] []
          , button [class "button is-primary", onClick (RegistrePresenca palestra.id estudante.matricula) ] [text "Registrar"]
          ]

    _ -> div [] []


mostrarMensagem : Maybe Mensagem -> Html Msg
mostrarMensagem maybeMensagem =
  case maybeMensagem of
    Nothing -> span [] []

    Just mensagem -> div [class ("notification " ++ mensagem.tipo)] [text mensagem.msg]
