-- Camada 1: tipos & consultas básicas
-- Campeonato de Speedrun de Minecraft
-- Duelos 1v1 , melhor de N seeds.

-- Adaptacoes do documento 
-- Time -> Speedrunner
-- Mandante / Visitante -> speedrunnerA / speedrunnerB
-- gols -> seedsVencidas (quem termina a seed mais rápido ganha 1 seed)

module Tipos
  ( Speedrunner 
  , Resultado(..)
  , Partida(..)
  , Linha(..)
  , participou
  , resultadoPara
  , times) where
  
import Data.List (nub, sort)

-- nome do speedrunner
type Speedrunner = String

-- Resultado de um duelo do ponto de vista de um speedrunner
data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq)
  
-- um duelo
data Partida = Partida
  { rodada :: Int
  , speedrunnerA :: Speedrunner
  , seedsA :: Int -- seeds ganhas por A
  , seedsB :: Int -- seeds ganhas por B
  , speedrunnerB :: Speedrunner
  } deriving (Show, Eq)
  
-- uma linha da tabela de classificacao
data Linha = Linha
  { speedrunner :: Speedrunner
  , jogos :: Int
  , vitorias :: Int
  , empates :: Int
  , derrotas :: Int
  , seedsPro :: Int
  , seedsContra :: Int
  } deriving (Show, Eq)
  
-- "o speedrunner participou dessa partida?"
participou :: Speedrunner -> Partida -> Bool
participou nome partida = nome == speedrunnerA partida || nome == speedrunnerB partida

-- resultado do ponto de vista do speedrunner, Nothing se ele nao participou
resultadoPara :: Speedrunner -> Partida -> Maybe Resultado
resultadoPara nome partida 
  | nome == speedrunnerA partida = Just(comparar (seedsA partida) (seedsB partida))
  | nome == speedrunnerB partida = Just(comparar (seedsB partida) (seedsA partida))
  | otherwise = Nothing
    where
      comparar proprio adversario = case compare proprio adversario of
        GT -> Vitoria
        EQ -> Empate
        LT -> Derrota
      
-- todos os speedrunners, sem repeticao e em ordem alfabetica
times :: [Partida] -> [Speedrunner]
times = sort . nub . concatMap (\partida -> [speedrunnerA partida, speedrunnerB partida])