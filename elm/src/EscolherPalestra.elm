module EscolherPalestra exposing (Model, Msg, init, update, view, palestraEscolhida)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Html.App as App

import Http
import Task
import Json.Decode as Json exposing((:=))

import String

import Palestra exposing (Palestra)
import Aviso

-- MODEL

type alias Model =
  {
    expirou : Bool,
    mbAno : Maybe Int,
    mbPalestra : Maybe Palestra,
    palestras : List Palestra,
    mbAviso : Maybe Aviso.Model
  }


init : Model
init =
  Model False Nothing Nothing [] Nothing

palestraEscolhida : Model -> Maybe Palestra
palestraEscolhida model =
  model.mbPalestra


-- UPDATE

type Msg =
  MsgAviso Aviso.Msg
  | DefinaAno String
  | BusquePalestrasDoAno
  | HttpErro Http.Error
  | HttpRespostaEncontrarPalestras (Maybe (List Palestra))
  | PalestraEscolhida Int


update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MsgAviso _ -> (model, Cmd.none) -- FIXME corrigir

    DefinaAno sAno ->
      case String.toInt sAno of
        Ok ano ->
          ({init | mbAno = Just ano}, Cmd.none)
        Err _ ->
          ({init | mbAviso = anoInvalido}, Cmd.none)

    BusquePalestrasDoAno ->
      case model.mbAno of
        Nothing -> ({model | mbAviso = Just (Aviso.init "Ano não definido!" "is-warning")}, Cmd.none)

        Just ano ->
          let
            mbAviso = Just (Aviso.init "Buscando palestras..." "is-info")
          in
            ({model | palestras = [], mbAviso = mbAviso}, buscarPalestras ano)

    HttpErro erro ->
      let
        mbAviso = Just (Aviso.init (toString erro) "is-danger")
      in
       ({model | mbAviso = mbAviso}, Cmd.none)

    HttpRespostaEncontrarPalestras mbPalestras ->
      case mbPalestras of
        Nothing -> sessaoExpirada

        Just palestras ->
          let
            mbAviso = case List.isEmpty palestras of
              True -> Just (Aviso.init "Não há palestras cadastradas" "is-warning")
              False -> Nothing
          in
            ({model | palestras = palestras, mbAviso = mbAviso}, Cmd.none)

    PalestraEscolhida idPalestra ->
      let
        f = \palestra -> palestra.id == idPalestra
        maybePalestra = List.head (List.filter f model.palestras)
      in
        ({model | mbPalestra = maybePalestra, mbAviso = Nothing}, Cmd.none)



anoInvalido : Maybe Aviso.Model
anoInvalido =
  Just (Aviso.init "Digite apenas números" "is-danger")

buscarPalestras : Int -> Cmd Msg
buscarPalestras ano =
  let
    url = Http.url "WSPalestra/encontrarPorAno" [("ano", toString(ano))]
  in
    Task.perform HttpErro HttpRespostaEncontrarPalestras (Http.get decoderMsgPalestrasEncontradas url)


decoderMsgPalestrasEncontradas : Json.Decoder (Maybe (List Palestra))
decoderMsgPalestrasEncontradas =
  ("Msg" := Json.string) `Json.andThen` dmpe

dmpe : String -> Json.Decoder (Maybe (List Palestra))
dmpe msg =
  case msg of
    "PalestrasEncontradas" -> Json.maybe (Palestra.decoderTodas)
    "UsuarioNaoLogado" -> Json.succeed Nothing
    _ -> Json.succeed  Nothing

sessaoExpirada : (Model, Cmd Msg)
sessaoExpirada =
  let
    mbAviso = Just (Aviso.init "Sessão expirada! Saia e entre novamente" "is-danger")
  in
    ({init | mbAviso = mbAviso, expirou = True}, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
  case model.expirou of
    True ->
      mostrarAviso model.mbAviso

    False ->
      view2 model


view2 : Model -> Html Msg
view2 model =
  div []
      [ span [] [text "Ano da Semana"]
      , input [type' "number", placeholder "ano", onInput DefinaAno] []
      , mostrarBotaoBuscarPalestras model.mbAno
      , escolherPalestra model.palestras
      , mostrarAviso model.mbAviso
      ]



mostrarBotaoBuscarPalestras : Maybe Int -> Html Msg
mostrarBotaoBuscarPalestras mbAno =
  case mbAno of
    Nothing  -> div [] []
    Just _ ->
      button
        [ class "button is-primary", onClick BusquePalestrasDoAno ]
        [ text "Buscar Palestras" ]


escolherPalestra : List Palestra -> Html Msg
escolherPalestra palestras =
  case List.isEmpty palestras of
    True -> div [] []

    False ->
      div [] [ mostrarPalestras palestras ]


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
          , name "idPalestra"
          , id (toString palestra.id)
          , value (toString palestra.id)
          , onClick  (PalestraEscolhida palestra.id)
          ]
          []

    mostrarSeleciona =
      \palestra ->
          div [class "notification is-primary"]
            [ (mostrarRadio palestra)
            , text "  "
            , label [for (toString palestra.id)] [text palestra.titulo ]
            ]

    montarLinha =
      \palestra ->
        div
          [class "panel"]
          [ div [class "panel-block"] [(mostrarSeleciona palestra) ]
--          , div [class "panel-block"] [ text palestra.titulo ]
          , div [class "panel-block"] [ text palestra.palestrante ]
          , div [class "panel-block"] [ (mostrarDiaEHorario palestra) ]
          ]

    linhas = List.map montarLinha palestras

  in
    div
      [ class "box" ]
      [ div [class "title"] [text "Escolher Palestra"]
      , div [] linhas
      ]


mostrarAviso : Maybe Aviso.Model -> Html Msg
mostrarAviso mbAviso =
  case mbAviso of
    Nothing  -> div [] []
    Just aviso -> App.map MsgAviso (Aviso.view aviso)
