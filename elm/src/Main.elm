import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Html.App as App

import Login
import Menu

main =
  App.program {init = init, view = view, update = update, subscriptions = subscriptions}

-- Model

type alias Model  =
  {
    login : Login.Model,
    menu : Menu.Model
  }

--
--
--
init : (Model, Cmd Msg)
init =
  (Model Login.init Menu.init, Cmd.none)


-- Subscriptions
-- Não é usado na aplicação

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- UPDATE

type Msg =
  LoginMsg Login.Msg
  | MenuMsg Menu.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoginMsg msg ->
      let
        (loginAtualizado, loginCmd) = Login.update msg model.login
      in
        ({ model | login = loginAtualizado }, Cmd.map LoginMsg loginCmd)

    MenuMsg msg ->
      let
        (menuAtualizado, menuCmd) = Menu.update msg model.menu
      in
      ({model | menu = menuAtualizado}, Cmd.map MenuMsg menuCmd)



-- View

view : Model -> Html Msg
view model =
  div [] [mostrarCabecalho, mostrarLogin model.login, mostrarMenu model.login.logado model.menu]

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


mostrarMenu : Bool -> Menu.Model -> Html Msg
mostrarMenu logado menu =
  case logado of
    True ->  div
              [class "box"]
              [App.map MenuMsg (Menu.view menu)]

    False -> div [] []
    
