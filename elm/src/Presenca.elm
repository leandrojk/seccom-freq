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
    matricula : Maybe Int,
    idPalestra : Maybe Int,
    mensagem : Maybe String
  }


init : Model
init =
  Model "" [] [] Nothing Nothing Nothing


-- UPDATE

type Msg =
  Ano String
  | BusquePalestras
  | HttpErro Http.Error
  | HttpRespostaEncontrarPalestras (List Palestra)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Ano sAno ->
      ({model | sAno = sAno, mensagem = Nothing }, Cmd.none)

    BusquePalestras ->
      let
        msg = Just "Buscando palestras..."
      in
      ({model | palestras = [], mensagem = msg}, buscarPalestras model.sAno)

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


buscarPalestras : String -> Cmd Msg
buscarPalestras sAno =
  let
    url = Http.url "WSPalestra/encontrarPorAno" [("ano", sAno)]
  in
--    Task.perform HttpErro HttpRespostaEncontrarPalestras (Http.get Json.string url)
    Task.perform HttpErro HttpRespostaEncontrarPalestras (Http.get Palestra.decoderTodas url)



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
    montarLinha = \palestra -> tr [] [td [] [text (toString palestra.id)], td [] [text palestra.titulo], td [] [text palestra.palestrante], td [] [text "o dia e o horário"]]
    linhas = List.map montarLinha palestras
  in
  div [class "box"]
    [ table []
        [ tr [] [th [] [text "Id"], th [] [text "Título"], th [] [text "Palestrante"], th [] [text "Dia e Horário"]]
        , tbody [] linhas
        ]
    ]

mostrarMensagem : Maybe String -> Html Msg
mostrarMensagem maybeMsg =
  case maybeMsg of
    Nothing -> span [] []

    Just msg -> div [class "notification is-info"] [text msg]
