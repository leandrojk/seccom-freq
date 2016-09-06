import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Html.App as App

import Login
import Menu
import Semana
import Palestra

main =
  App.program {init = init, view = view, update = update, subscriptions = subscriptions}

-- Model

type alias Model  =
  {
    login : Login.Model,
    menu : Menu.Model,
    semana : Semana.Model,
    palestra : Palestra.Model
  }

--
--
--
init : (Model, Cmd Msg)
init =
  (Model Login.init Menu.init Semana.init Palestra.init, Cmd.none)


-- Subscriptions
-- Não é usado na aplicação

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- UPDATE

type Msg =
  LoginMsg Login.Msg
  | MenuMsg Menu.Msg
  | SemanaMsg Semana.Msg
  | PalestraMsg Palestra.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoginMsg msg ->
      let
        (loginAtualizado, loginCmd) = Login.update msg model.login
      in
        ({ model | login = loginAtualizado , menu = Menu.init}, Cmd.map LoginMsg loginCmd)

    MenuMsg msg ->
      let
        (menuAtualizado, menuCmd) = Menu.update msg model.menu
      in
      ({model | menu = menuAtualizado}, Cmd.map MenuMsg menuCmd)

    SemanaMsg msg ->
      let
        (semanaAtualizada, semanaCmd) = Semana.update msg model.semana
      in
        ({model | semana = semanaAtualizada}, Cmd.map SemanaMsg semanaCmd)

    PalestraMsg msg ->
      let
        (palestraAtualizada, palestraCmd) = Palestra.update msg model.palestra
      in
        ({model | palestra = palestraAtualizada}, Cmd.map PalestraMsg palestraCmd)


-- View

view : Model -> Html Msg
view model =
  div []
      [
       mostrarLogin model.login
       , mostrarMenu model.login.logado model.menu
       , mostrarSemana (Menu.isSemana model.menu) model.semana
       , mostrarPalestra (Menu.isPalestra model.menu) model.palestra
       ]


mostrarLogin : Login.Model -> Html Msg
mostrarLogin login =
  div
    [class "box"]
    [
    div [class "title"] [text "SECCOM - CTC - UFSC - Controle de Frequência"]
    , App.map LoginMsg (Login.view login)
    ]


mostrarMenu : Bool -> Menu.Model -> Html Msg
mostrarMenu logado menu =
  case logado of
    True ->  div
              [class "box"]
              [App.map MenuMsg (Menu.view menu)]

    False -> div [] []

mostrarSemana : Bool -> Semana.Model -> Html Msg
mostrarSemana exibir model =
  case exibir of
    True ->
      div [class "box"] [App.map SemanaMsg (Semana.view model)]

    False -> div [] []


mostrarPalestra : Bool -> Palestra.Model -> Html Msg
mostrarPalestra exibir model =
  case exibir of
    True ->
      div [class "box"] [App.map PalestraMsg (Palestra.view model)]

    False -> div [] []
