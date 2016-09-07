module Presenca exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text, button, input, table, tbody, th, tr, td, span)
import Html.Attributes exposing (class, type', placeholder, value)
import Html.Events exposing (onClick, onInput)

import Http
import Task
import Json.Decode as Json exposing((:=))

import String

import Estudante exposing (Estudante)
import Palestra exposing (Palestra)

-- MODEL

type alias Model =
  {
    ano : Int,
    palestras : List Palestra,
    estudantes : List  Estudante
  }


init : Model
init =
  Model 0 [] []


-- UPDATE

type Msg = A

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)


-- VIEW
view : Model -> Html Msg
view model =
  div [] [text "presenca..."]
