-- main
module Main (main) where

import Classificacao
import Dados
import Leitura
import Tipos

main :: IO ()
main = do
  let secao titulo = "\n" ++ titulo
      mostrarErro erro = "ERRO: " ++ mensagemErro erro
      campeonato = lerCampeonato dadosCampeonato
  putStrLn (secao "0. consultas basicas da camada 1")
  let duelo = Partida 1 "Dream" 3 1 "Feinberg"
  print (resultadoPara "Dream" duelo)
  print (resultadoPara "Feinberg" duelo)
  print (resultadoPara "Benex" duelo)
  print (participou "Feinberg" duelo)
  print (participou "Benex" duelo)
  print (times campeonatoTeste)
  
  putStrLn (secao "1. Tabela final")
  either (putStrLn . mostrarErro) (putStr . tabelaFormatada . classificacao) campeonato

  putStrLn (secao "2. Tabela apos a rodada 3")
  either (putStrLn . mostrarErro) (putStr . tabelaFormatada . classificacao . ateRodada 3) campeonato

  putStrLn (secao "3. Estatisticas camada 2")
  either (putStrLn . mostrarErro) (putStr . relatorioEstatisticas) campeonato

  putStrLn (secao "4. Estatisticas de um campeonato vazio")
  putStr (relatorioEstatisticas [])

  putStrLn (secao "5. Entrada com erros")
  either (putStrLn . mostrarErro) (const (putStrLn "sem erros")) (lerCampeonato dadosComErros)

  putStrLn (secao "6. Entrada com erros, todosOsErros")
  mapM_ (putStrLn . mensagemErro) (todosOsErros dadosComErros)
