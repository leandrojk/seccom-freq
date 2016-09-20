module EscolherPalestra exposing (Model, init, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Html.App as App

import String

import Palestra exposing (Palestra)
import Aviso exposing (Aviso)

-- MODEL

type alias Model =
  {
    expirou : Bool,
    mbAno : Maybe Int,
    mbPalestra : Maybe Palestra,
    palestras : List Palestra,
    mbAviso : Maybe Aviso
  }


init : Model
init =
  Model False Nothing Nothing [] Nothing

-- UPDATE

type Msg = MsgAviso Aviso.Msg
     | DefinaAno String

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MsgAviso _ -> (model, Cmd.none)

    DefinaAno sAno ->
      case String.toInt sAno of
        Ok ano ->
          ({init | mbAno = Just ano}, Cmd.none)
        Err _ ->
          ({init | mbAviso = anoInvalido}, Cmd.none)


anoInvalido : Maybe Aviso
anoInvalido =
  Just (Aviso "Digite apenas números" "is-danger")


-- VIEW

view : Model -> Html Msg
view model =
  case model.expirou of
    True ->
      mostrarAviso model.mbAviso

    False ->
      view2 model


view2 : Model -> Html Msg
view2 model =
  div [] []


mostrarAviso : Maybe Aviso -> Html Msg
mostrarAviso mbAviso =
  case mbAviso of
    Nothing  -> div [] []
    Just aviso -> App.map MsgAviso (Aviso.view aviso)
