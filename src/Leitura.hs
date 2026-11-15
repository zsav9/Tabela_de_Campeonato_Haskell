-- Camada 3 
--  Formato da entrada:
--  rodada;speedrunnerA;seedsA;seedsB;speedrunnerB

module Leitura
  ( Erro(..)
  , separar
  , lerPartida
  , lerCampeonato
  , todosOsErros
  , mensagemErro
  , tabelaFormatada
  , relatorioEstatisticas
  ) where
  
import Classificacao
import Data.Char (isSpace)
import Data.List (dropWhileEnd, isPrefixOf, nub)
import Text.Read (readMaybe)
import Data.Maybe (fromMaybe, listToMaybe)
import Data.Either (lefts, rights)
import Tipos

data Erro
  = CamposInvalidos Int String
    | NumeroInvalido Int String
    | PlacarNegativo Int
    | MesmoSpeedrunner Int Speedrunner
    | SpeedrunnerRepetidoNaRodada Int Speedrunner
  deriving (Show, Eq)

  -- mensagem legivel para o usuario
mensagemErro :: Erro -> String
mensagemErro (CamposInvalidos numeroLinha texto) = "linha " ++ show numeroLinha ++ ": esperados 5 campos separados por ';' em \"" ++ texto ++ "\""
mensagemErro (NumeroInvalido numeroLinha campo) = "linha " ++ show numeroLinha ++ ": \"" ++ campo ++ "\" nao e um numero valido"
mensagemErro (PlacarNegativo numeroLinha) = "linha " ++ show numeroLinha ++ ": o placar nao pode ser negativo"
mensagemErro (MesmoSpeedrunner numeroLinha nome) = "linha " ++ show numeroLinha ++ ": " ++ nome ++ " nao pode jogar contra si mesmo"
mensagemErro (SpeedrunnerRepetidoNaRodada numeroRodada nome) = "rodada " ++ show numeroRodada ++ ": " ++ nome ++ " aparece em mais de um duelo"
  
separar :: Char -> String -> [String]
separar separador = foldr passo [[]]
  where
    passo caractere campos@(campoatual : resto) =
      if caractere == separador then [] : campos
      else (caractere : campoatual) : resto
    passo _ [] = [[]]
    
removeEspacos :: String -> String
removeEspacos = dropWhileEnd isSpace . dropWhile isSpace

paraEither :: e -> Maybe a -> Either e a
paraEither erro Nothing = Left erro
paraEither _ (Just x) = Right x

lerNumero :: Int -> String -> Either Erro Int
lerNumero numeroLinha campo = paraEither (NumeroInvalido numeroLinha campo) (readMaybe campo)

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

linhasUteis :: String -> [(Int, String)]
linhasUteis = filter (ehPartida . snd) . zip [1 ..] . lines
  where
    ehPartida linha = not (null (removeEspacos linha)) && not ("#" `isPrefixOf` removeEspacos linha)

-- quem aparece em mais de um duelo na mesma rodada
repeticoes :: [Partida] -> [(Int, Speedrunner)]
repeticoes partidas = concatMap repetidosDaRodada (nub (map rodada partidas))
  where
    repetidosDaRodada numeroRodada = map (\nome -> (numeroRodada, nome)) (repetidos (nomesDaRodada numeroRodada))
    nomesDaRodada numeroRodada = concatMap (\partida -> [speedrunnerA partida, speedrunnerB partida])
                (filter ((== numeroRodada) . rodada) partidas)
    repetidos nomes = nub (filter (\nome -> length (filter (== nome) nomes) > 1) nomes)

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (\(numeroLinha, linha) -> lerPartida numeroLinha linha) (linhasUteis texto)
  case repeticoes partidas of
    (numeroRodada, nome) : _ -> Left (SpeedrunnerRepetidoNaRodada numeroRodada nome)
    [] -> Right partidas

todosOsErros :: String -> [Erro]
todosOsErros texto = lefts resultados ++ map (\ (numeroRodada, nome) -> SpeedrunnerRepetidoNaRodada numeroRodada nome) (repeticoes (rights resultados))
  where
    resultados = map (\(numeroLinha, linha) -> lerPartida numeroLinha linha) (linhasUteis texto)

-- alinha o texto na coluna
alinharDireita :: Int -> String -> String
alinharDireita largura texto = replicate (largura - length texto) ' ' ++ texto

alinharEsquerda :: Int -> String -> String
alinharEsquerda largura texto = texto ++ replicate (largura - length texto) ' '

mostrarSaldo :: Int -> String
mostrarSaldo valor = if valor > 0 then "+" ++ show valor else show valor

linhaFormatada :: Int -> Linha -> String
linhaFormatada posicao linha = concat
  [ alinharDireita 3 (show posicao)
  , "  "
  , alinharEsquerda 14 (speedrunner linha)
  , alinharDireita 5 (show (pontosLinha linha))
  , alinharDireita 4 (show (jogos linha))
  , alinharDireita 4 (show (vitorias linha))
  , alinharDireita 4 (show (empates linha))
  , alinharDireita 4 (show (derrotas linha))
  , alinharDireita 7 (mostrarSaldo (saldo linha))
  ]

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = unlines (cabecalho : zipWith linhaFormatada [1 ..] linhas)
  where
    cabecalho = concat
      [ alinharDireita 3 "#"
      , "  "
      , alinharEsquerda 14 "Speedrunner"
      , alinharDireita 5 "Pts"
      , alinharDireita 4 "J"
      , alinharDireita 4 "V"
      , alinharDireita 4 "E"
      , alinharDireita 4 "D"
      , alinharDireita 7 "Saldo"
      ]

descreverPartida :: Partida -> String
descreverPartida partida = "rodada " ++ show (rodada partida) ++ ": " ++ speedrunnerA partida ++ " " ++ show (seedsA partida) ++ " x " ++ show (seedsB partida) ++ " " ++ speedrunnerB partida

-- estatisticas da Camada 2
relatorioEstatisticas :: [Partida] -> String
relatorioEstatisticas partidas = unlines
  [ "Duelos disputados: " ++ show (length partidas)
  , "Maior vantagem: " ++ maybe "nenhum duelo" descreverPartida (maiorVantagem partidas)
  , "Media de seeds por duelo: " ++ maybe "sem duelos" show (mediaSeeds partidas)
  , "Aproveitamento do lider: " ++ fromMaybe "sem duelos" (lider <$> listToMaybe (classificacao partidas))
  ]
  where
    lider linha = speedrunner linha ++ ", " ++ show (aproveitamento linha) ++ "%"
