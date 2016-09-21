module Relatorios exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Html.App as App

import EscolherPalestra
import Aviso
import Palestra exposing (Palestra)

-- MODEL

type alias Model = {
  ativo : Bool,
  expirou : Bool,
  mbAviso : Maybe Aviso.Model,
  palestraEscolhida : EscolherPalestra.Model
}

init : Model
init =
  Model False False Nothing EscolherPalestra.init

-- UPDATE

type Msg =
  MsgAviso Aviso.Msg
  | MsgEscolherPalestra EscolherPalestra.Msg
  | Ativar
  | Desativar
  | BusquePresencas

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    BusquePresencas ->
      (model, Cmd.none)

    MsgEscolherPalestra msg ->
      let
        (novoPalestra, comando) = EscolherPalestra.update msg model.palestraEscolhida
      in
       ({model | palestraEscolhida = novoPalestra}, Cmd.map MsgEscolherPalestra comando)

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
          , mostrarBotaoLerPresencas (EscolherPalestra.palestraEscolhida model.palestraEscolhida)
          ]


mostrarBotaoLerPresencas : Maybe Palestra -> Html Msg
mostrarBotaoLerPresencas mbPalestra =
  case mbPalestra of
    Nothing -> div [] []
    Just _ ->
      button
       [ class "button is-primary", onClick BusquePresencas]
       [ text "Buscar Estudantes Presentes" ]

viewMostreAviso : Maybe Aviso.Model -> Html Msg
viewMostreAviso mbAviso =
  case mbAviso of
    Nothing -> div [] []
    Just aviso -> App.map MsgAviso (Aviso.view aviso)
