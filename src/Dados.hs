-- Campeonato de teste
-- 6 speedrunners, 5 rodadas, todos  jogam contra todos
--
-- casos cobertos
-- empate em 0 x 0: rodada 1, Couriway x Illumina
-- vitoria por 3+ de diferenca: rodada 1, Dream 4 x 0 Feinberg
-- empate em pontos: dream e Techno terminam com 7 pontos, com o saldo de seeds desempatando (+2 x 0)
-- a tabela apos a rodada 3 tem outro lider que a final
--
-- Classificacao final:
--   pos  speedrunner  pts  J  V  E  D  pro  contra  saldo
--    1   Benex         13  5  4  1  0   10    3      +7
--    2   Dream          7  5  2  1  2    9    7      +2
--    3   Techno         7  5  2  1  2    9    9       0
--    4   Illumina       6  5  1  3  1    6    6       0
--    5   Couriway       5  5  1  2  2    7    8      -1
--    6   Feinberg       3  5  1  0  4    5   13      -8

module Dados
  ( campeonatoTeste
  , dadosCampeonato
  , dadosComErros
  ) where

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
  , Partida 5 "Feinberg" 2 1 "Illumina"
  ]


dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# rodada;speedrunnerA;seedsA;seedsB;speedrunnerB"
  , "1;Benex;2;1;Techno"
  , "1;Couriway;0;0;Illumina"
  , "1;Dream;4;0;Feinberg"
  , ""
  , "2;Benex;1;1;Illumina"
  , "2;Techno;3;2;Feinberg"
  , "2;Couriway;1;2;Dream"
  , ""
  , "3;Benex;2;0;Feinberg"
  , "3;Illumina;2;2;Dream"
  , "3;Techno;2;2;Couriway"
  , ""
  , "4;Benex;2;0;Dream"
  , "4;Feinberg;1;3;Couriway"
  , "4;Illumina;2;1;Techno"
  , ""
  , "5;Benex;3;1;Couriway"
  , "5;Dream;1;2;Techno"
  , "5;Feinberg;2;1;Illumina"
  ]

-- Texto com um erro de cada tipo
--   linha 3: placar "dois": erro NumeroInvalido
--   linha 4: so 4 campos: erro CamposInvalidos
--   linha 6: placar negativo: erro PlacarNegativo
--   linha 7: Techno contra Techno: erro MesmoSpeedrunner
--   linhas 8 e 9: Benex duas vezes na rodada 3: erro SpeedrunnerRepetidoNaRodada
dadosComErros :: String
dadosComErros = unlines
  [ "# campeonato com erros de digitacao"
  , "1;Benex;2;1;Techno"
  , "1;Couriway;dois;0;Illumina"
  , "1;Dream;4;0"
  , ""
  , "2;Benex;-1;1;Illumina"
  , "2;Techno;3;2;Techno"
  , "3;Benex;2;0;Feinberg"
  , "3;Dream;1;1;Benex"
  ]
