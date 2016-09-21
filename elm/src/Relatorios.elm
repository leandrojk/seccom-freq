module Relatorios exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Html.App as App
import Http
import Task
import Json.Decode as Json exposing((:=))

import EscolherPalestra
import Aviso
import Palestra exposing (Palestra)
import Estudante exposing (Estudante)

-- MODEL

type alias Model = {
  ativo : Bool,
  expirou : Bool,
  mbAviso : Maybe Aviso.Model,
  palestraEscolhida : EscolherPalestra.Model,
  mbEstudantes : Maybe (List Estudante),
  mbAviso : Maybe Aviso.Model
}

init : Model
init =
  Model False False Nothing EscolherPalestra.init Nothing Nothing

-- UPDATE

type Msg =
  MsgAviso Aviso.Msg
  | MsgEscolherPalestra EscolherPalestra.Msg
  | Ativar
  | Desativar
  | BusquePresencas
  | HttpErro Http.Error
  | HttpRespostaEstudantes (Maybe (List Estudante))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HttpErro erro ->
      let
        aviso = Aviso.init "Erro na resposta enviada pelo servidor" "is-danger"
      in
        ({model | mbAviso = Just aviso}, Cmd.none)

    HttpRespostaEstudantes mbEstudantes ->
      case mbEstudantes of
        Nothing -> sessaoExpirou

        Just _ ->
          ({model | mbEstudantes = mbEstudantes, mbAviso = Nothing }, Cmd.none)


    BusquePresencas ->
      case EscolherPalestra.palestraEscolhida model.palestraEscolhida of
        Nothing  -> (model, Cmd.none)

        Just palestra ->
          let
            mbAviso = Just (Aviso.init "Buscando estudantes..." "is-info")
          in
            ({model | mbEstudantes = Nothing, mbAviso = mbAviso}, buscarPresencas palestra.id)

    MsgEscolherPalestra msg ->
      let
        (novoPalestra, comando) = EscolherPalestra.update msg model.palestraEscolhida
      in
       ({model | palestraEscolhida = novoPalestra , mbEstudantes = Nothing}, Cmd.map MsgEscolherPalestra comando)

    MsgAviso msg ->
      case model.mbAviso of
        Nothing -> (model, Cmd.none)
        Just aviso ->
          let
            novoAviso = Aviso.update msg aviso
          in
            ({model | mbAviso = Just novoAviso}, Cmd.none)

    Ativar -> ({init | ativo = True}, Cmd.none)

    Desativar -> ({init | ativo = False}, Cmd.none)


buscarPresencas : Int -> Cmd Msg
buscarPresencas idPalestra =
  let
    url = Http.url "WSPresenca/encontrarEstudantesPorPalestra" [("palestra", toString(idPalestra))]
  in
    Task.perform HttpErro HttpRespostaEstudantes (Http.get decoderMsgEstudantesEncontrados url)


decoderMsgEstudantesEncontrados : Json.Decoder (Maybe (List Estudante))
decoderMsgEstudantesEncontrados =
  ("Msg" := Json.string) `Json.andThen` dee

dee : String -> Json.Decoder (Maybe (List Estudante))
dee msg =
  case msg of
    "EstudantesEncontrados" -> Json.maybe ( ("estudantes" := Json.list (Estudante.decoderVerdadeiro)))
    "UsuarioNaoLogado" -> Json.succeed Nothing
    _ -> Json.succeed Nothing

sessaoExpirou : (Model, Cmd Msg)
sessaoExpirou =
  let
    mbAviso = Just (Aviso.init "Sua sessão expirou. Saia e faça login" "is-danger")

  in
    ({init | mbAviso = mbAviso, expirou = True}, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
  case model.expirou of
    True -> viewMostreAviso model.mbAviso

    False -> view2 model


view2 : Model -> Html Msg
view2 model =
  case model.ativo of
    False ->
      div []
          [ button [class "tag is-primary", onClick Ativar]
                   [text "Relatórios"]
          ]

    True ->
      div [class "box"]
          [ button [class "tag is-info", onClick Desativar] [text "Fechar"]
          , div [class "title"] [text "Relatórios"]
          , App.map MsgEscolherPalestra (EscolherPalestra.view model.palestraEscolhida)
          , mostrarBotaoLerPresencas (EscolherPalestra.palestraEscolhida model.palestraEscolhida) model.mbEstudantes
          , mostrarEstudantesPresentes (EscolherPalestra.palestraEscolhida model.palestraEscolhida) model.mbEstudantes
          ]


mostrarBotaoLerPresencas : Maybe Palestra -> Maybe (List Estudante) -> Html Msg
mostrarBotaoLerPresencas mbPalestra mbEstudantes =
  case (mbPalestra, mbEstudantes) of
    (Nothing, _) -> div [] []
    (_, Just _) -> div [] []
    (Just _, _) ->
      button
       [ class "button is-primary", onClick BusquePresencas]
       [ text "Buscar Estudantes Presentes" ]


mostrarEstudantesPresentes : Maybe Palestra -> Maybe (List Estudante) -> Html Msg
mostrarEstudantesPresentes mbPalestra mbEstudantes =
  case mbEstudantes of
    Nothing -> div [] []

    Just estudantes ->
      case mbPalestra of
        Nothing -> div [] []

        Just palestra ->
          div
            [ class "box"]
            [ h3 [class "subtitle"] [text "Resultado"]
            , mostrarPalestra palestra
            , mostrarEstudantes estudantes
        ]

mostrarPalestra : Palestra -> Html Msg
mostrarPalestra palestra =
  div
    []
    [ h3 [] [text palestra.titulo]
    , p [] [text palestra.palestrante]
    , div [] [text "Dia ", text palestra.dia]
    ]

mostrarEstudantes : List Estudante -> Html Msg
mostrarEstudantes estudantes =
  case List.isEmpty estudantes of
    True ->
      div [] [h3 [] [text "Nenhum Estudante Presente"]]

    False ->
      div [] [h3 [] [text ("Há " ++ toString(List.length estudantes) ++ " estudantes presentes.")]]


viewMostreAviso : Maybe Aviso.Model -> Html Msg
viewMostreAviso mbAviso =
  case mbAviso of
    Nothing -> div [] []
    Just aviso -> App.map MsgAviso (Aviso.view aviso)
