-- Camada 2
-- Critérios de ordenação, do + ao - importante:
-- 1. mais pontos
-- 2. maior saldo de seeds (seedsPro - seedsContra)
-- 3. mais seeds a favor
-- 4.ordem alfabética


-- maiorVantagem: partida com maior diferença de seeds
module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  , classificacao
  , ateRodada
  , maiorVantagem 
  , mediaSeeds
  ) where
  
import Data.List (sortBy)
import Data.Maybe (fromMaybe, listToMaybe)
import Data.Ord (Down(..), comparing)
import Tipos

-- pontos ganhos em um duelo.
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

-- Linha de quem ainda nao jogou nada
linhaVazia :: Speedrunner -> Linha
linhaVazia nome = Linha nome 0 0 0 0 0 0

-- placar do ponto de vista do speedrunner: (seeds a favor, seeds contra).
placarPara :: Speedrunner -> Partida -> Maybe (Int, Int)
placarPara nome partida =
  if nome == speedrunnerA partida then Just (seedsA partida, seedsB partida)
  else if nome == speedrunnerB partida then Just (seedsB partida, seedsA partida)
  else Nothing


-- soma um duelo na linha do speedrunner, se ele nao jogou, a linha nao muda.
acumular :: Speedrunner -> Linha -> Partida -> Linha
acumular nome linha partida = fromMaybe linha novaLinha
  where
    novaLinha = do
      resultado <- resultadoPara nome partida
      (pro, contra) <- placarPara nome partida
      return linha
        { jogos = jogos linha + 1
        , vitorias = vitorias linha + fromEnum (resultado == Vitoria)
        , empates = empates linha + fromEnum (resultado == Empate)
        , derrotas = derrotas linha + fromEnum (resultado == Derrota)
        , seedsPro = seedsPro linha + pro
        , seedsContra = seedsContra linha + contra
        }
        
-- Linha da tabela de um speedrunner (percorre tds as partidas e acumula)
linhaDoTime :: [Partida] -> Speedrunner -> Linha
linhaDoTime partidas nome = foldl (acumular nome) (linhaVazia nome) partidas

-- Pontos totais de uma linha.
pontosLinha :: Linha -> Int
pontosLinha linha = pontos Vitoria * vitorias linha
  + pontos Empate * empates linha
  + pontos Derrota * derrotas linha

-- Saldo de seeds (a favor menos contra).
saldo :: Linha -> Int
saldo linha = seedsPro linha - seedsContra linha
    
-- Percentual dos pontos disputados que foram conquistados (0 se nao jogou).
aproveitamento linha =
  if jogos linha == 0 then 0
  else 100 * fromIntegral (pontosLinha linha) / fromIntegral (pontos Vitoria * jogos linha)
  
-- a tabela completa, uma linha por speedrunner, ordenada pelos criterios listados anteriormente
classificacao :: [Partida] -> [Linha]
classificacao partidas = sortBy criterio (map (linhaDoTime partidas) (times partidas))
  where
    criterio =
      comparing (Down . pontosLinha) <> comparing (Down . saldo)
       <> comparing (Down . seedsPro)
       <> comparing speedrunner
       
-- So os duelos ate a rodada informada (incluindo ela).
ateRodada :: Int -> [Partida] -> [Partida]
ateRodada limite = filter ((<= limite) . rodada)

-- Diferenca de seeds de um duelo (sempre positiva ou zero).
diferenca :: Partida -> Int
diferenca partida = abs (seedsA partida - seedsB partida)

-- Duelo com maior diferenca de seeds, em caso de empate, o mais antigo da lista
--  e Nothing para lista vazia
maiorVantagem :: [Partida] -> Maybe Partida
maiorVantagem = listToMaybe . sortBy (comparing (Down . diferenca))

-- Media de seeds por duelo; Nothing para lista vazia.
mediaSeeds :: [Partida] -> Maybe Double
mediaSeeds [] = Nothing
mediaSeeds partidas = Just (total / quantidade)
  where
    total = fromIntegral (sum (map ( \p -> seedsA p + seedsB p) partidas))
    quantidade = fromIntegral (length partidas)
