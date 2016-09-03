import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Html.App as App

import Login

main =
  App.program {init = init, view = view, update = update, subscriptions = subscriptions}

-- Model

type alias Model  =
  {
    login : Login.Model
  }

init : (Model, Cmd Msg)

init =
  (Model Login.init , Cmd.none)


-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- Update

type Msg = LoginMsg Login.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoginMsg msg ->
      let
        (loginAtualizado, loginCmd) = Login.update msg model.login
      in
        ({ model | login = loginAtualizado }, Cmd.map LoginMsg loginCmd)


-- View

view : Model -> Html Msg

view model =
  div
    [class "box"]
    [App.map LoginMsg (Login.view model.login)]
