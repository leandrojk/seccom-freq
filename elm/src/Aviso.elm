module Aviso exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)

-- MODEL

type alias Model = {
  texto : String,
  estilo : String
}

init : String -> String ->Model
init texto estilo =
  Model texto estilo

type Msg = Defina String String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Defina texto estilo ->
      init texto estilo


-- VIEW

view :  Model -> Html Msg
view model =
  div [class ("notification " ++ model.estilo)] [text model.texto]
