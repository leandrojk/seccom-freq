module Palestra exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- MODEL

type alias Model =
  {

  }

init : Model
init =
  Model

-- UPDATE

type Msg = A

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

-- VIEW
view : Model -> Html Msg
view model =
  div [class "box"] [text "a palestra..."]
