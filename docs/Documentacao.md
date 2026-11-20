# Decisões de modelagem e limitações
 
## Tema escolhido: speedrun de Minecraft
 
O enunciado permite outro esporte desde que a quantidade e a relação das funções se mantenham, então foram necessárias certas adaptações.
 
| Futebol | Campeonato Minecraft |
|---|---|
| Time | nome do `Speedrunner` |
| mandante / visitante | `speedrunnerA` / `speedrunnerB` |
| gols | seeds vencidas no duelo (quem termina a seed mais rápido ganha 1 referente a esse duelo) |
| pontos 3 / 1 / 0 | mantido. vitória 3, empate 1, derrota 0 |
 
Cada duelo é, como o nome implica, 1v1 e permite até 4 seeds. Uma seed em que ninguém termina não conta, então empates (inclusive 0 x 0) são possíveis.

**Nomes que mudaram em relação ao enunciado**

| Futebol | Campeonato Minecraft |
|---|---|
| `Time` | `Speedrunner` |
| `maiorGoleada` | `maiorVantagem` |
| `mediaGols` | `mediaSeeds` |
| `MesmoTime` | `MesmoSpeedrunner` |
| `TimeRepetidoNaRodada` | `SpeedrunnerRepetidoNaRodada` |
| campos `mandante`, `visitante`, `golsMandante`, `golsVisitante` | `speedrunnerA`, `speedrunnerB`, `seedsA`, `seedsB` |

Nomes como `participou`, `resultadoPara`, `times`, `linhaDoTime`, `ateRodada` e os demais foram mantidos. Time aqui também refere-se ao Speedrunner em questão.

## Campeonato de teste
 
`Dados.hs` tem 6 speedrunners, 5 rodadas e 15 duelos (todos contra todos), sem ninguém jogar duas vezes na mesma rodada. Ele cobre alguns casos excepcionais ou que poderiam gerar erros:

- um empate em 0 x 0
- uma vitória por 3 ou mais seeds de diferença
- dois speedrunners empatados em pontos: Dream e Techno terminam com 7 pontos, e o saldo de seeds os desempata;
- uma tabela intermediária após a rodada 3, com outro líder que a final.


## Decisoes por camadas

**Camada 1**

**Camada 2**

Um fator relevante para o funcionamento do sistema de pontuação foi o uso de maybe junto de just e nothing para cenários opcionais, ou seja, rodadas em que um speedrunner específico não tenha participado contra ninguém, assim os dados permaneciam sem ser alterados. Para a construção da tabela completa e sua ordenação, foi utilizado sortby e comparing, na parte do comparing o uso de Down foi escolhido para inverter a ordem e os speedrunners com mais pontos aparecerem primeiro, facilitando a ordenação, e em caso de empate, ele cai no próximo comparing que repete a operação mas com os outros fatores de avaliação, até termos uma ordem organizada.

**Camada 3**
