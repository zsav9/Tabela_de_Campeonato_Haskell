-- Camada 3 

module Leitura
  ( Erro(..)
  , separar
  , lerPartida
  ) where
  
import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import Text.Read (readMaybe)
import Tipos

data Erro
  = CamposInvalidos Int String
    | NumeroInvalido Int String
    | PlacarNegativo Int
    | MesmoSpeedrunner Int Speedrunner
  deriving (Show, Eq)
  

separar :: Char -> String -> [String]
separar separador = foldr passo [[]]
  where
    passo caractere campos@(campoatual : resto) =
      if caractere == separador then [] : campos
      else (caractere : campoatual) : resto
    passo _ [] = [[]]
    
removeEspacos :: String -> String
removeEspacos = dropWhileEnd isSpace . dropWhile isSpace

lerNumero :: Int -> String -> Either Erro Int
lerNumero numeroLinha campo = maybe (Left (NumeroInvalido numeroLinha campo)) Right (readMaybe campo)


lerPartida :: Int -> String -> Either Erro Partida
lerPartida numeroLinha linha =
  case map removeEspacos (separar ';' linha) of
    [campoRodada, nomeA, camposeedsA, camposeedsB, nomeB] -> do
      numeroRodada <- lerNumero numeroLinha campoRodada
      seedsdoA <- lerNumero numeroLinha camposeedsA
      seedsdoB <- lerNumero numeroLinha camposeedsB
      if seedsdoA < 0 then Left (PlacarNegativo numeroLinha)
      else if seedsdoB < 0 then Left (PlacarNegativo numeroLinha)
      else if nomeA == nomeB then Left (MesmoSpeedrunner numeroLinha nomeA)
      else Right (Partida numeroRodada nomeA seedsdoA seedsdoB nomeB)
    _ -> Left (CamposInvalidos numeroLinha linha)
