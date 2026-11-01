--protótipo main
module Main (main) 
    where

import Classificacao
import Dados (campeonatoTeste)
import Tipos

main :: IO ()
main = do
  putStrLn "Camada 1"
  let duelo = Partida 1 "Dream" 3 1 "Feinberg"
  print (resultadoPara "Dream" duelo)
  print (resultadoPara "Feinberg" duelo)
  print (resultadoPara "Benex" duelo)
  print (participou "Feinberg" duelo)
  print (times campeonatoTeste)

  putStrLn "Camada 2"
  mapM_ print (classificacao campeonatoTeste)
  print (map speedrunner (classificacao (ateRodada 3 campeonatoTeste)))
  print (maiorVantagem campeonatoTeste)
  print (mediaSeeds campeonatoTeste)