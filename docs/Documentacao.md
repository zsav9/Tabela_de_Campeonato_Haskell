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


decisoes por camadas