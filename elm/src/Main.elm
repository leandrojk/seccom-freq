import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Html.App as App

import Login

main =
  App.beginnerProgram {model = model, view = view, update = update}

-- Model

type alias Model  =
  {
    login : Login.Model
}

model : Model
model =
  {
    login = Login.init
  }

-- Update

type Msg = Login Login.Msg

update : Msg -> Model -> Model
update msg model =
  model


-- View

view : Model -> Html Msg

view model =
  div
    [class "box"]
    [App.map Login (Login.view model.login)]
