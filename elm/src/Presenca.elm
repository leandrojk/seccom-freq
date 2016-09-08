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
    sAno : String,
    palestras : List Palestra,
    estudantes : List  Estudante,
    sMatricula : Maybe String,
    idPalestra : Maybe Int,
    mensagem : Maybe String
  }


init : Model
init =
  Model "" [] [] Nothing Nothing Nothing


-- UPDATE

type Msg =
  Ano String
  | Matricula String
  | BusquePalestras
  | HttpErro Http.Error
  | HttpRespostaEncontrarPalestras (List Palestra)
  | PalestraEscolhida Int
  | PesquiseEstudante
  | HttpRespostaPesquisarEstudante Json.Value

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Ano sAno ->
      ({init | sAno = sAno}, Cmd.none)

    Matricula sMatricula ->
      ({model | sMatricula = Just sMatricula}, Cmd.none)

    PalestraEscolhida idPalestra ->
      ({model | idPalestra = Just idPalestra}, Cmd.none)

    BusquePalestras ->
      let
        msg = Just "Buscando palestras..."
      in
        ({model | palestras = [], mensagem = msg}, buscarPalestras model.sAno)

    PesquiseEstudante ->
      let
        msg = Just "Buscando estudante..."
      in
        ({model | mensagem = msg}, pesquisarEstudante model.sMatricula)

    HttpErro erro ->
      let
        msg = Just (toString erro)
      in
       ({model | mensagem = msg}, Cmd.none)

    HttpRespostaEncontrarPalestras palestras ->
      let
        msg = if (List.isEmpty palestras) then Just "Não há palestras cadastradas" else Nothing
      in
        ({model | palestras = palestras, mensagem = msg}, Cmd.none)

    HttpRespostaPesquisarEstudante json ->
      let
        mbEstudante = obterEstudante json
      in
        case mbEstudante of
          Nothing ->
            ({model | mensagem = Just "Estudante não cadastrado!"}, Cmd.none)

          Just estudante ->
            ({model | mensagem = Just estudante.nome}, Cmd.none)

buscarPalestras : String -> Cmd Msg
buscarPalestras sAno =
  let
    url = Http.url "WSPalestra/encontrarPorAno" [("ano", sAno)]
  in
--    Task.perform HttpErro HttpRespostaEncontrarPalestras (Http.get Json.string url)
    Task.perform HttpErro HttpRespostaEncontrarPalestras (Http.get Palestra.decoderTodas url)

pesquisarEstudante : Maybe String -> Cmd Msg
pesquisarEstudante mbSMatricula =
  case mbSMatricula of
    Nothing -> Cmd.none

    Just sMatricula ->
      let
        url = Http.url "WSEstudante/encontrarPorMatricula" [("matricula", sMatricula)]
      in
        Task.perform HttpErro HttpRespostaPesquisarEstudante (Http.get Json.value url)


obterEstudante : Json.Value -> Maybe Estudante
obterEstudante json =
  let
    result = Json.decodeValue decoderMsgEstudante json
--    result = Result.Ok (Just (Estudante 1010 "Fulano Fulano"))
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
      -- FIXME por que não esta funcionando?
       Json.maybe (Json.object2 Estudante ("matricula" := Json.int) ("nome" := Json.string))

    _ -> Json.maybe(Json.fail "parâmetro Msg não reconhecido")


obterPalestras : String -> List Palestra
obterPalestras respostaJson =
  let
    p = Palestra 77 1999 "ttt" "palestrante" "dia" "data i" "data t"
    q = Palestra 200 1999 "ttt" "palestrante" "dia" "data i" "data t"

    msg = Result.withDefault "erro" (Json.decodeString ("Msg" := Json.string) respostaJson)
    palestras = if msg == "PalestrasEncontradas" then Result.withDefault [p] (Json.decodeString Palestra.decoderTodas respostaJson) else [q]
  in
    [p,q]



-- VIEW
view : Model -> Html Msg
view model =
  div [class "box"]
    [ div [class "title"] [text "Registro de Presença"]
    , mostrarMensagem model.mensagem
    , span [] [text "Ano da Semana"]
    , input [type' "number", placeholder "ano", onInput Ano] []
    , button [class "button is-primary", onClick BusquePalestras] [text "Buscar Palestras"]
    , escolherPalestra model.palestras
    , escolherAluno model.palestras model.idPalestra
    ]

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
        []
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

escolherAluno : List Palestra -> Maybe Int -> Html Msg
escolherAluno palestras mbIdPalestra =
  case mbIdPalestra of
    Nothing -> div [] []

    Just idPalestra ->
      div
       [ class "box" ]
       [ div [class "title"] [text "Definir Estudante"]
       , span [] [text "Matrícula : "]
       , input [type' "number", onInput Matricula] []
       , button [class "button is-primary", onClick PesquiseEstudante] [text "Buscar Estudante"]
       ]


mostrarMensagem : Maybe String -> Html Msg
mostrarMensagem maybeMsg =
  case maybeMsg of
    Nothing -> span [] []

    Just msg -> div [class "notification is-info"] [text msg]
