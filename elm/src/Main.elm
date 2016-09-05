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

--
--
--
init : (Model, Cmd Msg)
init =
  (Model Login.init , Cmd.none)


-- Subscriptions
-- Não é usado na aplicação

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- UPDATE

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
  div [] [mostrarCabecalho, mostrarLogin model.login]

mostrarCabecalho : Html Msg
mostrarCabecalho =
  div [class "box"]
    [
      div [class "title"] [text "SECCOM - CTC - UFSC - Controle de Frequência"]
    ]

mostrarLogin : Login.Model -> Html Msg
mostrarLogin login =
  div
    [class "box"]
    [App.map LoginMsg (Login.view login)]
