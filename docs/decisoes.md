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

Por fim, a função `times` utiliza `concatMap`, `sort`, `group` e `mapMaybe listToMaybe` para reunir os participantes, remover nomes repetidos e organizá-los em ordem alfabética. A ordenação deixa a saída determinística e evita a busca quadrática de `nub`.

**Camada 2**

Um fator relevante para o funcionamento do sistema de pontuação foi o uso do `do` do `Maybe` junto de `fromMaybe` em `acumular`, para cenários opcionais, ou seja, duelos em que um speedrunner específico não tenha participado. Nesses casos, `resultadoPara` e `placarPara` devolvem `Nothing` e os dados permaneciam sem ser alterados.

Para construir a tabela, cada partida gera uma contribuição para cada participante. `sortBy` e `groupBy` agrupam essas contribuições por nome; `mapMaybe` e `foldl'` calculam uma linha por participante. A tabela final usa `sortBy`, `comparing` e `Down` para ordenar por pontos, saldo, seeds a favor e nome. Assim, a classificação evita percorrer todas as partidas novamente para cada participante.

Em `linhaDoTime`, `foldl'` percorre as partidas e aplica `acumular`; os campos numéricos de `Linha` são estritos para evitar acumular cálculos pendentes.

E para cenários em que só desejamos os dados de duelos até uma rodada informada (ela inclusa), utilizamos `filter`, que percorre a lista e mantém apenas os elementos que satisfazem a condição passada `((<=limite) . rodada)`. O operador ponto é utilizado para a composição de funções, no caso apresentado, é primeiro extraído o número da rodada de cada partida, através de `rodada`, e em seguida é comparado ao limite informado, o mantendo somente se menor ou igual.

`mediaSeeds` usa `map` e `sum` para contar as seeds e converte os valores para `Integer` antes da soma. `maiorVantagem` usa uma única dobra e preserva a primeira partida em caso de empate na diferença.

**Camada 3**

A terceira camada começa com a definição do tipo `Erro`, onde são apresentados os diferentes casos de erros que podem acontecer durante a leitura e validação dos dados. Com o uso do `deriving (Show, Eq) `, o `Show` permite gerar representações textuais para os erros e o `Eq` permite comparar dois erros para conferir se são iguais. As mensagens de erro apresentadas são criadas através de `mensagemErro`, que recebe o erro e retorna uma string com uma mensagem clara para o usuário, incluindo a linha onde o erro ocorreu quando aplicável.

Em seguida a função `separar` utiliza `foldr` para percorrer a string caractere por caractere, dividindo o conteúdo sempre que encontra o separador `;`. Dessa forma, cada linha do arquivo é transformada em uma lista de campos, permitindo identificar a rodada, os nomes dos speedrunners e suas respectivas seeds. Em seguida, a função `removeEspacos` utiliza `dropWhile` e `dropWhileEnd` para remover espaços desnecessários do início e do final de cada campo, evitando problemas durante a leitura.

Em `lerNumero`, `readMaybe` lê primeiro um `Integer`. Só há conversão para `Int` quando o valor cabe nesse tipo; caso contrário, `paraEither` devolve `NumeroInvalido`.

Em `lerPartida`, a notação `do` de `Either` lê rodada e placares, retornando o primeiro erro da linha. Depois, valida rodada positiva (`RodadaInvalida`), nomes não vazios (`NomeVazio`), placares não negativos (`PlacarNegativo`), participantes distintos (`MesmoSpeedrunner`) e no máximo quatro seeds vencidas no duelo (`SeedsExcedidas`). Uma linha sem cinco campos devolve `CamposInvalidos`.

Já em `lerCampeonato`, o `traverse` aplica `lerPartida` a cada linha útil do texto (`linhasUteis`, que preserva a numeração original). Se alguma linha falhar, devolve o primeiro erro; se todas passarem, `repeticoes` procura participantes que aparecem em mais de um duelo na mesma rodada usando ordenação e agrupamento.

A função `todosOsErros` verifica separadamente os campos e as regras de cada linha, podendo relatar mais de um erro independente na mesma linha. Também procura repetições entre linhas com rodada e nomes reconhecíveis, mesmo quando o placar da linha é inválido. Para linhas sem cinco campos ou sem rodada válida, não há dados suficientes para verificar repetições.

Finalizando, apenas `main` faz `IO`, e só imprime o que as funções calculam. Não tem `getLine`, pois os dados do campeonato ficam em `Dados.hs`, como `String`.

**Limitações conhecidas**

- "Dream" e "dream" são tratados como speedrunners diferentes; só se removem os espaços das pontas no tratamento.
- Os nomes dos speedrunners não podem conter `;`.
- Não há confronto direto, como desempate.
- Os construtores exportados de `Partida` e `Linha` permitem criar diretamente valores fora das regras; a validação ocorre na leitura textual.
- Em linhas com quantidade errada de campos, `todosOsErros` relata `CamposInvalidos`; os campos ausentes não podem ser validados individualmente.

