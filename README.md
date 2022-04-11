# Calculador-de-dipolo

O script atualmente não tem erros ao colocar dados de resposta que não são esperados
alem do nome do experimento no inicio, todas as respostas são apenas números! 
se for usar separador decimal utilize ponto

atualmente há na base tanto moléculas polares como apolares, os valores para os cálculos foram retirados do nist.
as geometrias das moléculas utilizadas foram otimizadas no gauss view utilizando o metodo B3LYP/6-31G.
deixe a pasta /base no mesmo diretório que dipolomachine.sh

############################ Dipolo Ion Machine ######################################################################

Utiliza o programa PSI 4 para calcular dipolo e dipolo induzido de diferentes moléculas que estão na base com íons
Esse cálculo de energia é comparado com os valores da equação derivada de cálculo de energia potencial.

ao rodar o script pela primeira vez pode ser necessário dar permissão a ele, então com o terminal no diretorio digite
chmod a+x dipolo-ion-machine.sh;

Os arquivos do experimento estarão em uma pasta no diretório onde está o script, 
Dentro da pasta haverá dois arquivos txt, um com os valores calculados com o PSI4 (calculo_quantico_....txt)
outro com os valores calculados pela equação derivada (calculo_derivado_....txt)

o comando para rodar o script é 
./dipolo-ion-machine.sh 4.0 Li +1
Em que 4.0 é a distância inicial no eixo z, em angstroms, que pode ser tanto negativa como positiva,
Li é o símbolo atômico do íon desejado e +1 a sua carga

Depois é só obedecer os comandos do programa

Exemplo de uso, colocando os comandos quando pedido
./dipolomachine.sh 4.0 Li +1
litio_agua_frente
1 
0 
1
0.5

Então é só esperar!

############################ Dipolo Dipolo Machine ######################################################################

Utiliza o programa PSI 4 para calcular potencial eletrostático, de dispersão e de indução de diferentes moléculas que estão na base.

ao rodar o script pela primeira vez pode ser necessário dar permissão a ele, então com o terminal no diretorio digite
chmod a+x dipolo-dipolo-machine.sh;

Os arquivos do experimento estarão em uma pasta no diretório onde está o script, 
Dentro da pasta haverá um arquivos txt, um com os valores calculados com o PSI4 (calculo_quantico_....txt)

o comando para rodar o script é 
./dipolo-dipolo-machine.sh 4.0
Em que 4.0 é a distância inicial no eixo z, em angstroms.

Depois é só obedecer os comandos do programa

Exemplo de uso, colocando os comandos quando pedido
./dipolo-dipolo-machine.sh 4.0
agua_agua
1 
0 
0.1
0.5

Então é só esperar!

