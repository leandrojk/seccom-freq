module Estudante exposing (Estudante, decoderEstudante, decoderVerdadeiro)

import Json.Decode as Json exposing((:=))

-- MODEL

type alias Estudante =
  { matricula : Int
  , nome : String
  }

--
-- O objeto JSON deve conter o atributo estudante cujo valor deve ser
-- um objeto JSON contendo os atributos matricula e nome.
--
-- Exemplo : decodifica o objeto JSON
--
-- { ... "estudante": {"matricula": 10102010, "nome": "Fulano de Tal"}  ...}
--
-- para o objeto Elm
--
-- Estudante 10102010 "Fulano de Tal"
--

--FIXME o decoder tem que atuar apenas no objeto {matricula ...  nome}
decoderEstudante : Json.Decoder Estudante
decoderEstudante =
  "estudante" := Json.object2 Estudante ("matricula" := Json.int) ("nome" := Json.string)

decoderVerdadeiro : Json.Decoder Estudante
decoderVerdadeiro =
  Json.object2 Estudante ("matricula" := Json.int) ("nome" := Json.string)
