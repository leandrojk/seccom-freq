module Login exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, input, button, h3)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type', class)

-- MODEL

type alias Model =
  {
  senhaDigitada : String,
  classeDoBotao : String
  }

init : Model
init =
  Model "vaca" "button is-primary"

-- UPDATE

type Msg
  = ArmazeneSenha String
  | EnvieSenha

update : Msg -> Model -> Model

update msg model =
  case msg of
    ArmazeneSenha senha ->
      { model | senhaDigitada = senha }

    EnvieSenha ->
      { model | classeDoBotao = "button is-danger" }

-- VIEW

view : Model -> Html Msg

view model =
  div []
    [ h3 [class "title"] [text "Login"]
    , input [ type' "text", placeholder "Código", onInput ArmazeneSenha ] []
--    , button [ class model.classeDoBotao, onClick EnvieSenha ] [text  model.classeDoBotao]
    , h3 [] [text model.senhaDigitada]
    ]
