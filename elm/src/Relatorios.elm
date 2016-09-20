module Relatorios exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Html.App as App

import EscolherPalestra
import Aviso

-- MODEL

type alias Model = {
  ativo : Bool,
  expirou : Bool,
  mbAviso : Maybe Aviso.Aviso,
  palestraEscolhida : EscolherPalestra.Model
}

init : Model
init =
  Model False False Nothing EscolherPalestra.init

-- UPDATE

type Msg =  MsgAviso Aviso.Msg
  | Ativar
  | Desativar

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MsgAviso _ -> (model, Cmd.none)

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
          ]



viewMostreAviso : Maybe Aviso.Aviso -> Html Msg
viewMostreAviso mbAviso =
  case mbAviso of
    Nothing -> div [] []
    Just aviso -> App.map MsgAviso (Aviso.view aviso)
