-- main
module Main (main) where

import Classificacao
import Dados
import Leitura

main :: IO ()
main = do
  secao "1. Tabela final"
  either mostrarErro (putStr .tabelaFormatada . classificacao) (lerCampeonato dadosCampeonato)

  secao "2. Tabela apos a rodada 3"
  either mostrarErro (putStr .tabelaFormatada . classificacao . ateRodada 3) (lerCampeonato dadosCampeonato)

  secao "3. Estatisticas camada 2"
  either mostrarErro (putStr .relatorioEstatisticas) (lerCampeonato dadosCampeonato)

  secao "4. Estatisticas de um campeonato vazio"
  putStr (relatorioEstatisticas [])

  secao "5. Entrada com erros"
  either mostrarErro (const (putStrLn "sem erros")) (lerCampeonato dadosComErros)

  secao "6. Entrada com erros, todosOsErros"
  mapM_ (putStrLn . mensagemErro) (todosOsErros dadosComErros)

secao :: String -> IO ()
secao titulo = putStrLn ("\n" ++ titulo)

mostrarErro :: Erro -> IO ()
mostrarErro erro = putStrLn ("ERRO:" ++ mensagemErro erro)
