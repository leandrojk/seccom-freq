import Html exposing (Html, div, text)
import Html.App as X

main =
  X.beginnerProgram {model = model, view = view, update = update}

-- Model

type alias Model  = Int

model : Model
model =
  0

-- Update

type Msg = I | D

update : Msg -> Model -> Model
update msg model =
  model


-- View

view : Model -> Html Msg

view model =
  div [] [text "paralamas"]
