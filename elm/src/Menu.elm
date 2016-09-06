module Menu exposing (Model, Msg, init, update, view, isSemana, isPalestra)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

-- MODEL

type alias Model =
  {
    opcaoAtual : Maybe Opcao
  }

init : Model
init =
  Model Nothing

type Opcao = OpcaoSemana | OpcaoPalestra

isSemana : Model -> Bool
isSemana model =
  opcaoAtual model OpcaoSemana

isPalestra : Model -> Bool
isPalestra model =
  opcaoAtual model OpcaoPalestra

opcaoAtual : Model -> Opcao -> Bool
opcaoAtual model opcao =
  case model.opcaoAtual of
    Nothing -> False

    Just op -> op == opcao


-- UPDATE

type Msg = Semana | Palestra

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Semana ->
      ({model | opcaoAtual = Just OpcaoSemana}, Cmd.none)

    Palestra ->
      ({model | opcaoAtual = Just OpcaoPalestra}, Cmd.none)


-- VIEW

view : Model -> Html Msg

view model =
  div [class "box"]
      [
        div [class "columns"]
            [
              div [class "column"] [button [class "button is-primary", onClick Semana] [text "Semana"]]
              , div [class "column"] [button [class "button is-primary", onClick Palestra] [text "Palestra"]]
            ]
      ]
