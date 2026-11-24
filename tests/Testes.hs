-- testes

import Classificacao
import Dados
import Leitura
import Tipos
import System.Exit (exitFailure)

testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado = if obtido == esperado then putStrLn ("ok " ++ nome)
  else do
    putStrLn ("falhou " ++ nome ++ ": obtido " ++ show obtido ++ ", esperado " ++ show esperado)
    exitFailure


duelo :: Partida
duelo = Partida 1 "Dream" 3 1 "Techno"

resumo :: Linha -> (Speedrunner, Int, Int)
resumo linha = (speedrunner linha, pontosLinha linha, saldo linha)

main :: IO ()
main = do
  putStrLn "Camada 1"
  testar "resultadoPara: A vence" (resultadoPara "Dream" duelo) (Just Vitoria)
  testar "resultadoPara: B perde" (resultadoPara "Techno" duelo) (Just Derrota)
  testar "resultadoPara: quem nao jogou" (resultadoPara "Benex" duelo) Nothing
  testar "resultadoPara: empate" (resultadoPara "Dream" (Partida 1 "Dream" 0 0 "Techno")) (Just Empate)
  testar "participou: quem jogou" (participou "Techno" duelo) True
  testar "participou: quem nao jogou" (participou "Benex" duelo) False
  testar "times: sem repeticao e em ordem alfabetica"
    (times campeonatoTeste)
    ["Benex", "Couriway", "Dream", "Feinberg", "Illumina", "Techno"]
  testar "times: lista vazia" (times []) []
  testar "campeonato de teste respeita o limite de quatro seeds"
    (all (\partida -> seedsA partida + seedsB partida <= 4) campeonatoTeste) True

  putStrLn "Camada 2"
  testar "classificacao completa (conferida previamente)"
    (classificacao campeonatoTeste)
    [ Linha "Benex" 5 4 1 0 10 3
    , Linha "Dream" 5 2 1 2 9 7
    , Linha "Techno" 5 2 1 2 8 8
    , Linha "Illumina" 5 1 3 1 6 6
    , Linha "Couriway" 5 1 2 2 7 8
    , Linha "Feinberg" 5 1 0 4 4 12
    ]
  testar "desempate por saldo: Dream e Techno com 7 pts (+2 contra 0)"
    (filter (\(nome, _, _) -> nome `elem` ["Dream", "Techno"]) (map resumo (classificacao campeonatoTeste)))
    [("Dream", 7, 2), ("Techno", 7, 0)]
  testar "desempate por seeds a favor"
    (map speedrunner (classificacao [Partida 1 "Ana" 1 0 "Bia", Partida 1 "Cris" 2 1 "Duda"]))
    ["Cris", "Ana", "Duda", "Bia"]
  testar "desempate por ordem alfabetica"
    (map speedrunner (classificacao [Partida 1 "Cris" 1 0 "Duda", Partida 1 "Ana" 1 0 "Bia"]))
    ["Ana", "Cris", "Bia", "Duda"]
  testar "classificacao ate a rodada 3"
    (map resumo (classificacao (ateRodada 3 campeonatoTeste)))
    [ ("Dream", 7, 5), ("Benex", 7, 3), ("Techno", 4, 0)
    , ("Illumina", 3, 0), ("Couriway", 2, -1), ("Feinberg", 0, -7) ]
  testar "o lider apos a rodada 3 (Dream) é diferente do lider final (Benex)"
    (map speedrunner (classificacao (ateRodada 3 campeonatoTeste))
       /= map speedrunner (classificacao campeonatoTeste))
    True
  testar "ateRodada 3 devolve so os 9 duelos das rodadas 1, 2 e 3" (length (ateRodada 3 campeonatoTeste)) 9
  testar "classificacao de lista vazia e uma tabela vazia" (classificacao []) []
  testar "pontos" (map pontos [Vitoria, Empate, Derrota]) [3, 1, 0]
  testar "linhaDoTime de quem nao jogou" (linhaDoTime campeonatoTeste "Ninguem") (Linha "Ninguem" 0 0 0 0 0 0)
  testar "aproveitamento de quem nao jogou" (aproveitamento (Linha "X" 0 0 0 0 0 0)) 0
  testar "aproveitamento do Benex: 13 de 15 pontos possiveis (86,67%)"
    (abs (aproveitamento (linhaDoTime campeonatoTeste "Benex") - 100 * 13 / 15) < 1e-9)
    True
  testar "maiorVantagem lista vazia" (maiorVantagem []) Nothing
  testar "mediaSeeds lista vazia" (mediaSeeds []) Nothing
  testar "maiorVantagem do campeonato: Dream 4 x 0 Feinberg (diferenca de 4 seeds)" (maiorVantagem campeonatoTeste) (Just (Partida 1 "Dream" 4 0 "Feinberg"))
  testar "maiorVantagem preserva a primeira partida no empate"
    (maiorVantagem [Partida 1 "Ana" 3 0 "Bia", Partida 2 "Cris" 0 3 "Duda"])
    (Just (Partida 1 "Ana" 3 0 "Bia"))
  testar "mediaSeeds do campeonato (44 seeds em 15 duelos)" (mediaSeeds campeonatoTeste) (Just (44 / 15))

  putStrLn "Camada 3"
  testar "separar" (separar ';' "a;b;;c") ["a", "b", "", "c"]
  testar "separar de texto vazio" (separar ';' "") [""]
  testar "lerPartida valida" (lerPartida 1 "1;Ana;1;0;Bia") (Right (Partida 1 "Ana" 1 0 "Bia"))
  testar "lerPartida ignora espacos nas extremidades" (lerPartida 1 " 1 ; Ana ; 1 ; 0 ; Bia ") (Right (Partida 1 "Ana" 1 0 "Bia"))
  testar "lerPartida aceita quatro seeds no total"
    (lerPartida 1 "1;Ana;2;2;Bia") (Right (Partida 1 "Ana" 2 2 "Bia"))
  testar "lerCampeonato valido devolve right" (lerCampeonato dadosCampeonato) (Right campeonatoTeste)
  testar "lerCampeonato ignora comentarios e linhas em branco"
    (lerCampeonato "# c\n\n  \n1;Ana;1;0;Bia\n")
    (Right [Partida 1 "Ana" 1 0 "Bia"])
  testar "lerCampeonato de texto vazio" (lerCampeonato "") (Right [])
  testar "erro CamposInvalidos" (lerPartida 1 "1;Dream;4;0") (Left (CamposInvalidos 1 "1;Dream;4;0"))
  testar "erro NumeroInvalido (placar \"dois\")" (lerPartida 2 "1;Couriway;dois;0;Illumina") (Left (NumeroInvalido 2 "dois"))
  testar "erro NumeroInvalido (\"2a\")" (lerPartida 2 "1;Ana;2a;0;Bia") (Left (NumeroInvalido 2 "2a"))
  testar "erro PlacarNegativo (lado A)" (lerPartida 3 "2;Benex;-1;1;Illumina") (Left (PlacarNegativo 3))
  testar "erro PlacarNegativo (lado B)" (lerPartida 3 "2;Benex;1;-1;Illumina") (Left (PlacarNegativo 3))
  testar "erro RodadaInvalida (zero)" (lerPartida 3 "0;Ana;1;0;Bia") (Left (RodadaInvalida 3))
  testar "erro RodadaInvalida (negativa)" (lerPartida 3 "-1;Ana;1;0;Bia") (Left (RodadaInvalida 3))
  testar "erro NomeVazio (lado A)" (lerPartida 3 "1; ;1;0;Bia") (Left (NomeVazio 3))
  testar "erro NomeVazio (lado B)" (lerPartida 3 "1;Ana;1;0; ") (Left (NomeVazio 3))
  testar "erro SeedsExcedidas" (lerPartida 3 "1;Ana;3;2;Bia") (Left (SeedsExcedidas 3))
  testar "numero acima de Int nao e aceito"
    (lerPartida 3 ("1;Ana;" ++ show (toInteger (maxBound :: Int) + 1) ++ ";0;Bia"))
    (Left (NumeroInvalido 3 (show (toInteger (maxBound :: Int) + 1))))
  testar "erro MesmoSpeedrunner" (lerPartida 4 "2;Techno;3;2;Techno") (Left (MesmoSpeedrunner 4 "Techno"))
  testar "erro SpeedrunnerRepetidoNaRodada"
    (lerCampeonato "3;Benex;2;0;Feinberg\n3;Dream;1;1;Benex")
    (Left (SpeedrunnerRepetidoNaRodada 3 "Benex"))
  testar "lerCampeonato para no primeiro erro" (lerCampeonato dadosComErros) (Left (NumeroInvalido 3 "dois"))
  testar "todosOsErros lista todos os 5 erros e nao apenas o primeiro"
    (todosOsErros dadosComErros)
    [ NumeroInvalido 3 "dois"
    , CamposInvalidos 4 "1;Dream;4;0"
    , PlacarNegativo 6
    , MesmoSpeedrunner 7 "Techno"
    , SpeedrunnerRepetidoNaRodada 3 "Benex"
    ]
  testar "todosOsErros de entrada valida" (todosOsErros dadosCampeonato) []
  testar "todosOsErros detecta repeticao mesmo com placar invalido"
    (todosOsErros "1;Ana;1;0;Bia\n1;Ana;dois;0;Cris")
    [NumeroInvalido 2 "dois", SpeedrunnerRepetidoNaRodada 1 "Ana"]
  testar "todosOsErros relata varios erros independentes da mesma linha"
    (todosOsErros "0; ; -1;2;Bia")
    [RodadaInvalida 1, NomeVazio 1, PlacarNegativo 1]
  testar "todosOsErros relata todos os campos numericos invalidos"
    (todosOsErros "x;Ana;dois;?;Ana")
    [NumeroInvalido 1 "x", NumeroInvalido 1 "dois", NumeroInvalido 1 "?",
      MesmoSpeedrunner 1 "Ana"]
  testar "todosOsErros de texto vazio" (todosOsErros "") []
  testar "tabelaFormatada tem cabecalho + 6 linhas"
    (length (lines (tabelaFormatada (classificacao campeonatoTeste))))
    7
  testar "tabelaFormatada de lista vazia, so o cabecalho" (length (lines (tabelaFormatada []))) 1
  testar "tabelaFormatada alinha nomes longos"
    (case map length (lines (tabelaFormatada
      [Linha "SpeedrunnerComNomeLongo" 1 1 0 0 1 0, Linha "Bia" 1 0 0 1 0 1])) of
      [cabecalho, primeira, segunda] -> cabecalho == primeira && primeira == segunda
      _ -> False)
    True
  testar "tabelaFormatada separa colunas numericas largas"
    (case map length (lines (tabelaFormatada
      [Linha "Ana" 100000 100000 0 0 100000 0, Linha "Bia" 1 0 0 1 0 1])) of
      [cabecalho, primeira, segunda] -> cabecalho == primeira && primeira == segunda
      _ -> False)
    True
