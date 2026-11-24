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
import Data.List (dropWhileEnd, group, intercalate, isPrefixOf, sort, transpose)
import qualified Data.List as List (foldl')
import Text.Read (readMaybe)
import Data.Maybe (fromMaybe, listToMaybe, mapMaybe)
import Data.Either (lefts, rights)
import Tipos

data Erro
  = CamposInvalidos Int String
    | NumeroInvalido Int String
    | RodadaInvalida Int
    | NomeVazio Int
    | PlacarNegativo Int
    | SeedsExcedidas Int
    | MesmoSpeedrunner Int Speedrunner
    | SpeedrunnerRepetidoNaRodada Int Speedrunner
  deriving (Show, Eq)

  -- mensagem legivel para o usuario
mensagemErro :: Erro -> String
mensagemErro (CamposInvalidos numeroLinha texto) = "linha " ++ show numeroLinha ++ ": esperados 5 campos separados por ';' em \"" ++ texto ++ "\""
mensagemErro (NumeroInvalido numeroLinha campo) = "linha " ++ show numeroLinha ++ ": \"" ++ campo ++ "\" nao e um numero valido"
mensagemErro (RodadaInvalida numeroLinha) = "linha " ++ show numeroLinha ++ ": a rodada deve ser positiva"
mensagemErro (NomeVazio numeroLinha) = "linha " ++ show numeroLinha ++ ": os nomes dos speedrunners nao podem estar vazios"
mensagemErro (PlacarNegativo numeroLinha) = "linha " ++ show numeroLinha ++ ": o placar nao pode ser negativo"
mensagemErro (SeedsExcedidas numeroLinha) = "linha " ++ show numeroLinha ++ ": o duelo pode ter no maximo 4 seeds vencidas"
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
lerNumero numeroLinha campo = paraEither (NumeroInvalido numeroLinha campo) numero
  where
    numero = do
      valor <- readMaybe campo :: Maybe Integer
      if valor >= toInteger (minBound :: Int) && valor <= toInteger (maxBound :: Int)
        then Just (fromInteger valor)
        else Nothing

lerPartida :: Int -> String -> Either Erro Partida
lerPartida numeroLinha linha =
  case map removeEspacos (separar ';' linha) of
    [campoRodada, nomeA, camposeedsA, camposeedsB, nomeB] -> do
      numeroRodada <- lerNumero numeroLinha campoRodada
      seedsdoA <- lerNumero numeroLinha camposeedsA
      seedsdoB <- lerNumero numeroLinha camposeedsB
      if numeroRodada <= 0 then Left (RodadaInvalida numeroLinha)
      else if null nomeA || null nomeB then Left (NomeVazio numeroLinha)
      else if seedsdoA < 0 then Left (PlacarNegativo numeroLinha)
      else if seedsdoB < 0 then Left (PlacarNegativo numeroLinha)
      else if nomeA == nomeB then Left (MesmoSpeedrunner numeroLinha nomeA)
      else if toInteger seedsdoA + toInteger seedsdoB > 4 then Left (SeedsExcedidas numeroLinha)
      else Right (Partida numeroRodada nomeA seedsdoA seedsdoB nomeB)
    _ -> Left (CamposInvalidos numeroLinha linha)

linhasUteis :: String -> [(Int, String)]
linhasUteis = filter (ehPartida . snd) . zip [1 ..] . lines
  where
    ehPartida linha = not (null (removeEspacos linha)) && not ("#" `isPrefixOf` removeEspacos linha)

-- quem aparece em mais de um duelo na mesma rodada
repeticoes :: [Partida] -> [(Int, Speedrunner)]
repeticoes = repeticoesDe . concatMap identidades
  where
    identidades partida =
      [(rodada partida, speedrunnerA partida), (rodada partida, speedrunnerB partida)]

repeticoesDe :: [(Int, Speedrunner)] -> [(Int, Speedrunner)]
repeticoesDe = mapMaybe listToMaybe . filter ((> 1) . length) . group . sort

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (\(numeroLinha, linha) -> lerPartida numeroLinha linha) (linhasUteis texto)
  case repeticoes partidas of
    (numeroRodada, nome) : _ -> Left (SpeedrunnerRepetidoNaRodada numeroRodada nome)
    [] -> Right partidas

todosOsErros :: String -> [Erro]
todosOsErros texto = concatMap errosDaLinha uteis
  ++ map (\(numeroRodada, nome) -> SpeedrunnerRepetidoNaRodada numeroRodada nome)
    (repeticoesDe (concatMap identidadesReconhecidas uteis))
  where
    uteis = linhasUteis texto
    errosDaLinha (numeroLinha, linha) =
      case map removeEspacos (separar ';' linha) of
        [campoRodada, nomeA, campoA, campoB, nomeB] ->
          let numeroRodada = lerNumero numeroLinha campoRodada
              numeroA = lerNumero numeroLinha campoA
              numeroB = lerNumero numeroLinha campoB
              errosNumeros = lefts [numeroRodada, numeroA, numeroB]
              erroRodada = case numeroRodada of
                Right valor | valor <= 0 -> [RodadaInvalida numeroLinha]
                _ -> []
              erroNome = [NomeVazio numeroLinha | null nomeA || null nomeB]
              erroPlacar = [PlacarNegativo numeroLinha |
                any (< 0) (rights [numeroA, numeroB])]
              erroMesmo = [MesmoSpeedrunner numeroLinha nomeA |
                not (null nomeA) && nomeA == nomeB]
              erroSeeds = case (numeroA, numeroB) of
                (Right a, Right b) | a >= 0 && b >= 0
                  && toInteger a + toInteger b > 4 -> [SeedsExcedidas numeroLinha]
                _ -> []
          in errosNumeros ++ erroRodada ++ erroNome ++ erroPlacar
            ++ erroMesmo ++ erroSeeds
        _ -> [CamposInvalidos numeroLinha linha]
    identidadesReconhecidas (numeroLinha, linha) =
      case map removeEspacos (separar ';' linha) of
        [campoRodada, nomeA, _, _, nomeB] ->
          case lerNumero numeroLinha campoRodada of
            Right numeroRodada | numeroRodada > 0 ->
              map (\nome -> (numeroRodada, nome))
                (filter (not . null)
                  (if nomeA == nomeB then [nomeA] else [nomeA, nomeB]))
            _ -> []
        _ -> []

-- alinha o texto na coluna
alinharDireita :: Int -> String -> String
alinharDireita largura texto = replicate (largura - length texto) ' ' ++ texto

alinharEsquerda :: Int -> String -> String
alinharEsquerda largura texto = texto ++ replicate (largura - length texto) ' '

mostrarSaldo :: Int -> String
mostrarSaldo valor = if valor > 0 then "+" ++ show valor else show valor

camposLinha :: Int -> Linha -> [String]
camposLinha posicao linha =
  [ show posicao
  , speedrunner linha
  , show (pontosLinha linha)
  , show (jogos linha)
  , show (vitorias linha)
  , show (empates linha)
  , show (derrotas linha)
  , mostrarSaldo (saldo linha)
  ]

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = unlines (map formatar (cabecalho : dados))
  where
    cabecalho = ["#", "Speedrunner", "Pts", "J", "V", "E", "D", "Saldo"]
    dados = zipWith camposLinha [1 ..] linhas
    larguras = map (List.foldl' max 0 . map length) (transpose (cabecalho : dados))
    formatar campos = intercalate "  " (zipWith3 alinhar [0 :: Int ..] larguras campos)
    alinhar indice largura texto
      | indice == 1 = alinharEsquerda largura texto
      | otherwise = alinharDireita largura texto

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
