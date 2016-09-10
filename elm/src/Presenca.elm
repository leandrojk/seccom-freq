module Presenca exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Http
import Task
import Json.Decode as Json exposing((:=))

import String

import Estudante exposing (Estudante)
import Palestra exposing (Palestra)

-- MODEL

type alias Model =
  {
    ano : Maybe Int,
    palestras : List Palestra,
    palestra : Maybe Palestra,
    estudante : Maybe  Estudante,
    matricula : Maybe Int,
    idPalestra : Maybe Int,
    mensagem : Maybe Mensagem

  }

type alias Mensagem =
  { msg : String
  , tipo : String  -- tipos válidos para o CSS
  }

init : Model
init =
  Model Nothing [] Nothing Nothing Nothing Nothing Nothing


-- UPDATE

type Msg =
  Ano String
  | Matricula String
  | BusquePalestras
  | HttpErro Http.Error
  | HttpRespostaEncontrarPalestras (List Palestra)
  | PalestraEscolhida Int
  | PesquiseEstudante
  | HttpRespostaPesquisarEstudante (Maybe Estudante)
  | RegistrePresenca Int Int
  | HttpRespostaRegistrarPresenca Bool

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Ano sAno ->
      case String.toInt sAno of
        Ok ano ->
          ({init | ano = Just ano}, Cmd.none)

        Err _ ->
          ({init | mensagem = Just (Mensagem "Digite apenas números" "is-danger")}, Cmd.none)

    Matricula sMatricula ->
      case String.toInt sMatricula of
        Ok matricula ->
          ({model | matricula = Just matricula, mensagem = Nothing, estudante = Nothing}, Cmd.none)

        Err _ ->
          let
            mensagem = Just (Mensagem "Digite apenas números" "is-danger")
          in
            ({model | matricula = Nothing, estudante = Nothing, mensagem = mensagem}, Cmd.none)

    PalestraEscolhida idPalestra ->
      let
        f = \palestra -> palestra.id == idPalestra
        maybePalestra = List.head (List.filter f model.palestras)
      in
      ({model | idPalestra = Just idPalestra, palestra = maybePalestra}, Cmd.none)

    BusquePalestras ->
      case model.ano of
        Nothing -> ({model | mensagem = Just (Mensagem "Ano não definido!" "is-warning")}, Cmd.none)

        Just ano ->
          let
            msg = Just (Mensagem "Buscando palestras..." "is-info")
          in
            ({model | palestras = [], mensagem = msg}, buscarPalestras ano)

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

    HttpRespostaEncontrarPalestras palestras ->
      let
        msg = case List.isEmpty palestras of
          True -> Just (Mensagem "Não há palestras cadastradas" "is-warning")
          False -> Nothing
      in
        ({model | palestras = palestras, mensagem = msg}, Cmd.none)

    HttpRespostaPesquisarEstudante maybeEstudante ->
        case maybeEstudante of
          Nothing ->
            ({model | mensagem = Just (Mensagem "Estudante não cadastrado!" "is-warning")}, Cmd.none)

          Just estudante ->
            ({model | estudante = maybeEstudante, mensagem = Nothing}, Cmd.none)

    RegistrePresenca idPalestra matricula->
      let
        sm = toString matricula
        sid = toString idPalestra
        url = Http.url "WSPresenca/cadastrar" [("matricula", sm), ("palestra", sid)]
        comando = Task.perform HttpErro HttpRespostaRegistrarPresenca (Http.post decoderRespostaRegistrarPresenca url Http.empty)
      in
        ({model | mensagem = Just (Mensagem "registrando..." "is-info")}, comando)

    HttpRespostaRegistrarPresenca registrou ->
      let
        msg = case registrou of
          True -> Just (Mensagem "Presença registrada com sucesso" "is-success")
          False -> Just (Mensagem "Presença já havia sido registrada" "is-warning")
      in
        ({model | mensagem = msg}, Cmd.none)

--
--

buscarPalestras : Int -> Cmd Msg
buscarPalestras ano =
  let
    url = Http.url "WSPalestra/encontrarPorAno" [("ano", toString(ano))]
  in
    Task.perform HttpErro HttpRespostaEncontrarPalestras (Http.get Palestra.decoderTodas url)

pesquisarEstudante : Int -> Cmd Msg
pesquisarEstudante matricula =
  let
    url = Http.url "WSEstudante/encontrarPorMatricula" [("matricula", toString(matricula))]
  in
    Task.perform HttpErro HttpRespostaPesquisarEstudante (Http.get decoderMsgEstudante url)


obterEstudante : Json.Value -> Maybe Estudante
obterEstudante json =
  let
    result = Json.decodeValue decoderMsgEstudante json
  in
    case result of
      Err e -> Nothing

      Ok mbEstudante -> mbEstudante


decoderMsgEstudante : Json.Decoder (Maybe Estudante)
decoderMsgEstudante =
  ("Msg" := Json.string) `Json.andThen`  dme

dme : String -> Json.Decoder (Maybe Estudante)
dme msg =
  case msg of
    "EstudanteNaoEncontrado" -> Json.maybe (Json.fail "aluno não cadastrado")

    "EstudanteEncontrado" ->
       Json.maybe (("estudante" := Json.object2 Estudante ("matricula" := Json.int) ("nome" := Json.string)))

    _ -> Json.maybe(Json.fail "parâmetro Msg não reconhecido")

decoderRespostaRegistrarPresenca : Json.Decoder Bool
decoderRespostaRegistrarPresenca =
  ("Msg" := Json.string) `Json.andThen` drrp

drrp : String -> Json.Decoder Bool
drrp msg =
  case msg of
    "PresencaCadastrada" -> Json.succeed True
    "PresencaJaCadastrada" -> Json.succeed False
    _ -> Json.succeed False




-- VIEW
view : Model -> Html Msg
view model =
  div [class "box"]
    [ div [class "title"] [text "Registro de Presença"]
    , span [] [text "Ano da Semana"]
    , input [type' "number", placeholder "ano", onInput Ano] []
    , mostrarBotaoBuscarPalestras model.ano
    , escolherPalestra model.palestras
    , escolherAluno model.idPalestra model.matricula
    , registrarPresenca (model.palestra, model.estudante)
    , mostrarMensagem model.mensagem
    ]

mostrarBotaoBuscarPalestras : Maybe Int -> Html Msg
mostrarBotaoBuscarPalestras mbAno =
  case mbAno of
    Nothing  -> div [] []
    Just _ ->
      button
        [ class "button is-primary", onClick BusquePalestras ]
        [ text "Buscar Palestras" ]


escolherPalestra : List Palestra -> Html Msg
escolherPalestra palestras =
  case List.isEmpty palestras of
    True -> div [] []

    False ->
      div []
        [ mostrarPalestras palestras

        ]

mostrarPalestras : List Palestra -> Html Msg
mostrarPalestras palestras =
  let
    mostrarDiaEHorario =
      \palestra ->
        div
          []
          [ text "Dia : "
          , text palestra.dia
          , br [] []
          , text "Horário : "
          , text palestra.horarioDeInicio
          , text " -- "
          , text palestra.horarioDeTermino
          , text " hs"]

    mostrarRadio =
      \palestra ->
        input
          [ type' "radio"
          , name "id"
          , value (toString palestra.id)
          , onClick  (PalestraEscolhida palestra.id)
          ]
          []



    montarLinha =
      \palestra ->
        tr
          []
          [ td [] [ (mostrarRadio palestra), text "  ", text (toString palestra.id) ]
          , td [] [ text palestra.titulo ]
          , td [] [ text palestra.palestrante ]
          , td [] [ (mostrarDiaEHorario palestra) ]
          ]

    linhas = List.map montarLinha palestras

  in
  div
    [ class "box" ]
    [ div [class "title"] [text "Escolher Palestra"]
    , table
        [ class "table"]
        [ tr
            []
            [ th [] [text "Selecione"]
            , th [] [text "Título"]
            , th [] [text "Palestrante"]
            , th [] [text "Dia e Horário"]
            ]
        , tbody [] linhas
        ]
    ]

escolherAluno : Maybe Int -> Maybe Int -> Html Msg
escolherAluno mbIdPalestra mbMatricula =
  case mbIdPalestra of
    Nothing -> div [] []

    Just idPalestra ->
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
            , span []
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
          , span [class "subtitle"] [text "Estudante : "]
          , span [] [text (toString estudante.matricula), text " -- ", text estudante.nome]
          , br [] []
          , button [class "button is-primary", onClick (RegistrePresenca palestra.id estudante.matricula) ] [text "Registrar"]
          ]

    _ -> div [] []


mostrarMensagem : Maybe Mensagem -> Html Msg
mostrarMensagem maybeMensagem =
  case maybeMensagem of
    Nothing -> span [] []

    Just mensagem -> div [class ("notification " ++ mensagem.tipo)] [text mensagem.msg]