module Aviso exposing (Aviso, Msg, view)

import Html exposing (..)
import Html.Attributes exposing (..)

type alias Aviso = {
  texto : String,
  estilo : String
}

type Msg = Nada

-- VIEW

view :  Aviso -> Html Msg
view aviso =
  div [class ("notification " ++ aviso.estilo)] [text aviso.texto]
