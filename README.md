# Tabela de Campeonato Haskell: Competição de Speedrun de Minecraft

Campeonato de speedrun de Minecraft, com duelos 1v1 e até 4 seeds por duelo. Os resultados são lidos de um texto

**Ambiente usado:** GHC local instalado via GHCup.  O código também foi testado no play.haskell.org.

## Estrutura
 
```
projeto/
├── src/
│   ├── Tipos.hs  Camada 1
│   ├── Classificacao.hs  Camada 2
│   ├── Leitura.hs    Camada 3
│   ├── Dados.hs          campeonato de teste
│   └── Main.hs           demonstração das três camadas
├── tests/Testes.hs       testes com resultado esperado
├── docs/decisoes.md      decisões de modelagem e limitações
```

## Como compilar e executar (GHC local)
 
Na pasta do projeto:
 
```
ghc -Wall -isrc -outputdir build src/Main.hs -o build/speedrun
./build/speedrun
```

Ou, sem gerar executável: `runghc -isrc src/Main.hs`

## Como rodar os testes
 
```
runghc -isrc tests/Testes.hs
```

## Formato da entrada
 
Uma partida por linha, campos separados por `;`. Linhas em branco e linhas que começam com `#` são ignoradas.
 
```
# rodada;speedrunnerA;seedsA;seedsB;speedrunnerB
1;Mine;2;1;Craft
```
