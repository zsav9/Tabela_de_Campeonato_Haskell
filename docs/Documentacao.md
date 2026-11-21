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


### Camada 1

Para representar os dados do campeonato, foi utilizado um sinônimo de tipo (`type Speedrunner = String`) para identificar os participantes pelo nome. Essa escolha permite trabalhar diretamente com nomes, mantendo o código simples e deixando as assinaturas das funções mais descritivas.

O tipo `Resultado` foi definido como um tipo soma, com três possibilidades: `Vitoria`, `Empate` e `Derrota`. Dessa forma, os resultados ficam padronizados, evitando o uso de números ou textos para representar cada situação. Os valores desse tipo representam o resultado de uma partida pela perspectiva de um speedrunner específico, podendo ser diferentes dependendo de qual participante está sendo consultado.

Para representar os duelos, foi utilizado o tipo `Partida` com campos nomeados (record), contendo a rodada, os dois speedrunners e a quantidade de seeds vencidas por cada um (`speedrunnerA`, `seedsA`, `seedsB` e `speedrunnerB`). Essa estrutura facilita o acesso às informações e diminui a possibilidade de confundir os participantes e seus respectivos resultados.

Também foi criado o tipo `Linha`, responsável por armazenar os dados individuais de cada speedrunner na classificação, como quantidade de jogos, vitórias, empates, derrotas, seeds a favor e seeds contra.

Na função `participou`, foi utilizada uma comparação entre o nome informado e os dois participantes da partida, retornando um valor booleano que indica se aquele speedrunner participou do duelo.

Na função `resultadoPara`, foi utilizado o tipo `Maybe Resultado`, retornando `Just` com o resultado correspondente quando o speedrunner participou da partida e `Nothing` quando não participou. Essa escolha permite representar situações em que não existe um resultado para determinado participante, sem precisar criar um resultado artificial. Internamente, a função auxiliar `comparar` usa `compare` e converte `GT`, `EQ` e `LT` em `Vitoria`, `Empate` e `Derrota`. Como a mesma lógica vale para A e para B, basta inverter a ordem dos argumentos, o que evita duplicar código.

Por fim, a função `times` utiliza `concatMap`, `nub` e `sort` para reunir os participantes de todas as partidas, remover nomes repetidos e organizar a lista em ordem alfabética. A ordenação deixa a saída determinística, o que facilita os testes e a tabela final.

**Camada 2**

Um fator relevante para o funcionamento do sistema de pontuação foi o uso de `maybe` junto de `just` e `nothing` para cenários opcionais, ou seja, rodadas em que um speedrunner específico não tenha participado contra ninguém, assim os dados permaneciam sem ser alterados.

Para a construção da tabela completa e sua ordenação, foi utilizado `sortby` e `comparing`, na parte do comparing o uso de `Down` foi escolhido para inverter a ordem e os speedrunners com mais pontos aparecerem primeiro, facilitando a ordenação, e em caso de empate, ele cai no próximo comparing que repete a operação mas com os outros fatores de avaliação, até termos uma ordem organizada.

Já nas partidas que foram jogadas, o `foldl` é utilizado na função `linhaDoTime` para percorrer a lista com todas as partidas do campeonato, da esquerda para a direita, mantendo a linha do participante atualizada progressivamente por meio da função `acumular`, que é aplicada a cada duelo.

E para cenários em que só desejamos os dados de duelos até uma rodada informada (ela inclusa), utilizamos `filter`, que percorre a lista e mantém apenas os elementos que satisfazem a condição passada `((<=limite) . rodada)`. O operador ponto é utilizado para a composição de funções, no caso apresentado, é primeiro extraído o número da rodada de cada partida, através de `rodada`, e em seguida é comparado ao limite informado, o mantendo somente se menor ou igual.

Por último, o `map` é utilizado tanto em `classificacao` e `mediaSeeds`, porém com intuito diferente. Em `classificacao` (`sortBy criterio (map (linhaDoTime partidas) (times partidas))`) ele aplica a função `linhaDoTime` a cada participante retornado por `times partidas`, transformando a lista de nomes dos participantes em uma lista de linhas de classificação. Já em `mediaSeeds` (`sum (map (\p -> seedsA p + seedsB p) partidas)`), o map aplica a função lambda `(\p -> seedsA p + seedsB p)`, somando as seeds conquistadas pelos dois speedrunners de cada duelo e gerando uma nova lista contendo o total de seeds de cada partida, posteriormente usada pela função `sum`.

**Camada 3**

A terceira camada começa com a definição do tipo `Erro`, onde são apresentados os diferentes casos de erros que podem acontecer durante a leitura e validação dos dados. Com o uso do `deriving (Show, Eq) `, o `Show` permite gerar representações textuais para os erros e o `Eq` permite comparar dois erros para conferir se são iguais. As mensagens de erro apresentadas são criadas através de `mensagemErro`, que recebe o erro e retorna uma string com uma mensagem clara para o usuário, incluindo a linha onde o erro ocorreu quando aplicável.

