import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Html.App as App

import Login
import Presenca

main =
  App.program {init = init, view = view, update = update, subscriptions = subscriptions}

-- Model

type alias Model  =
  {
    login : Login.Model,
    presenca : Presenca.Model
  }

--
--
--
init : (Model, Cmd Msg)
init =
  (Model Login.init Presenca.init, Cmd.none)


-- Subscriptions
-- Não é usado na aplicação

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- UPDATE

type Msg =
  LoginMsg Login.Msg
  | PresencaMsg Presenca.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoginMsg msg ->
      let
        (loginAtualizado, loginCmd) = Login.update msg model.login
        (novoModelo, _) = init
      in
        ({ novoModelo | login = loginAtualizado }, Cmd.map LoginMsg loginCmd)

    PresencaMsg msg ->
      case Login.estaLogado model.login of
        False -> init
        True ->
          let
            (presencaAtualizada, presencaCmd) = Presenca.update msg model.presenca
          in
            ({model | presenca = presencaAtualizada}, Cmd.map PresencaMsg presencaCmd)

-- View

view : Model -> Html Msg
view model =
  case Login.estaLogado model.login of
    False ->
      div [] [mostrarLogin model.login]

    True ->
      div []
        [ mostrarLogin model.login
        , mostrarPresenca  model.presenca
        ]


mostrarLogin : Login.Model -> Html Msg
mostrarLogin login =
  div
    [class "box"]
    [ div [class "title"] [text "SECCOM - CTC - UFSC - Controle de Frequência"]
    , App.map LoginMsg (Login.view login)
    ]


mostrarPresenca :  Presenca.Model -> Html Msg
mostrarPresenca  presencaModel =
  div [class "box"]
    [App.map PresencaMsg (Presenca.view presencaModel)]
