module Dados (campeonatoTeste) where
import Tipos
campeonatoTeste :: [Partida]
campeonatoTeste =
  [ Partida 1 "Benex" 2 1 "Techno"
  , Partida 1 "Couriway" 0 0 "Illumina"
  , Partida 1 "Dream" 4 0 "Feinberg"
  , Partida 2 "Benex" 1 1 "Illumina"
  , Partida 2 "Techno" 3 2 "Feinberg"
  , Partida 2 "Couriway" 1 2 "Dream"
  , Partida 3 "Benex" 2 0 "Feinberg"
  , Partida 3 "Illumina" 2 2 "Dream"
  , Partida 3 "Techno" 2 2 "Couriway"
  , Partida 4 "Benex" 2 0 "Dream"
  , Partida 4 "Feinberg" 1 3 "Couriway"
  , Partida 4 "Illumina" 2 1 "Techno"
  , Partida 5 "Benex" 3 1 "Couriway"
  , Partida 5 "Dream" 1 2 "Techno"
  , Partida 5 "Feinberg" 2 1 "Illumina"]