# Tabela de Campeonato Haskell: Competição de Speedrun de Minecraft

Campeonato de speedrun de Minecraft, com duelos 1v1 e até 4 seeds por duelo. Os resultados são lidos de um texto, validados com `Maybe` e `Either`, e a tabela de classificação é calculada só com funções de ordem superior.

**Ambiente usado:** GHC local instalado via GHCup, compilado com `-Wall`. O código também foi testado no play.haskell.org.

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

Cada linha da saída começa com `ok` ou `falhou`. São 42 testes no total.

## Sobre o `main`
 
0. Consultas básicas da Camada 1.
1. A tabela final.
2. A tabela após rodada intermediária, com líder diferente da final.
3. As estatísticas da Camada 2 (maior vantagem, média de seeds, aproveitamento do líder).
4. As mesmas estatísticas para um campeonato vazio.
5. Uma entrada com erros, lida por `lerCampeonato`.
6. A mesma entrada, lida por `todosOsErros`.
Os dados do campeonato ficam no próprio código (`Dados.hs`), como `String`.

## Formato da entrada
 
Uma partida por linha, campos separados por `;`. Linhas em branco e linhas que começam com `#` são ignoradas.

 
```
# rodada;speedrunnerA;seedsA;seedsB;speedrunnerB
1;Mine;2;1;Craft
```

## Classificação
 
Nesse sistema, a vitória vale 3, empate vale 1 e derrota vale 0. Os critérios de ordenação são, nesta ordem:
 
1. mais pontos
2. maior saldo de seeds (seeds a favor menos seeds contra)
3. mais seeds a favor
4. ordem alfabética
Na tabela impressa, as colunas são: posição, speedrunner, pontos (Pts), jogos (J), vitórias (V), empates (E), derrotas (D) e saldo.

## Decisões e limitações
 
Veja `docs/decisoes.md`
