module Estudante exposing (Estudante, decoderEstudante)

import Json.Decode as Json exposing((:=))

-- MODEL

type alias Estudante =
  { matricula : Int
  , nome : String
  }

decoderEstudante : Json.Decoder Estudante
decoderEstudante =
  "estudante" := Json.object2 Estudante ("matricula" := Json.int) ("nome" := Json.string)
