#!/bin/bash

#constantes do laço while principal
i=0
f=0

echo "Bem vindo ao calculador de dipolo-dipolo 9000!"
echo "..."

dist=$1
echo "Informe o nome do experimento"
read nomeexp;

echo "Informe a molecula que deseja"
echo "polar (1) ou apolar(0) ?"
read polar;
if [[ $polar == 1 ]];
then
    listpolar=("h20" "hcl" "hf" "ch3f")
    echo "${listpolar[@]:0}, indique de 0 a 3"
    read nmolecula;
    molecula=${listpolar[$nmolecula]}
else
    listapolar=("n2" "f2" "cl2" "ch4")
    echo "${listapolar[@]:0}, indique de 0 a 3"
    read nmolecula;
    molecula=${listapolar[$nmolecula]}
fi

echo "você escolheu $molecula"
echo "..."


string1="    Electrostatics          "
string2="    Induction          "
string3="    Dispersion                     "

mkdir $nomeexp || echo "$nomeexp diretório já existe"

# limpa os arquivos de execuções anteriores
rm -f $nomeexp/*.out
rm -f $nomeexp/*.dat
rm -f $nomeexp/*.txt

arquivoquant=$(echo "$nomeexp/calculo_quantico_$nomeexp.txt")

echo "Cálculos Quânticos de $string1, $string2, $string3 de $nomeexp" >> $arquivoquant
echo "Distância[Angstrom]; Eletrostatica Energia[kJ/mol; Inducao Energia[kJ/mol]; Dispersao Energia[kJ/mol]; Potencial de Van der Waals [kJ/mol]" >> $arquivoquant

echo "..."
echo "insira o parâmetro de energia mínima"
read parametro;
echo "..."
echo "insira o incremento de distância"
read incr;

if [[ $(echo "$1 < 0" | bc ) -eq 1 ]];
then
    echo "multiplicando incremento por menos 1"
    incr=$(echo "$incr * -1" | bc -l)
fi

echo "O parâmetro para menor energia é $parametro; o incremento de distância é $incr"
echo "..."

while [[ "$f" != "1" ]];
do

echo "Início dos cálculos, distância utilizada será $dist"
##############################calculoquantico######################

#cria os arquivos de entrada e saida
arquivodat=$nomeexp/$nomeexp$dist.dat
arquivoout=$nomeexp/$nomeexp$dist.out

#coloca o cabecalho
cat >> $arquivodat << EOF 
molecule {
    0 1
EOF

#introduz primeira molecula no dat
cat base/$molecula.txt >> $arquivodat

#separa as moleculas
cat >> $arquivodat << EOF
    --
    0 1
EOF


while read -r line; do
    mystrings=${line% *}
    myints=${line##* }
    int2=$(echo "${myints} + ${dist}" | bc -l)
    echo "    ${mystrings} ${int2}" >> $arquivodat
done < base/$molecula.txt

cat >> $arquivodat << EOF

    units angstrom
    no_reorient
    no_com
    symmetry c1
}

set basis jun-cc-pvdz

energy('sapt0')
EOF

echo "escrevi $arquivodat"

psi4 "$arquivodat"
echo "rodei psi4 $arquivodat"

linha1=$(grep "$string1" "$arquivoout" | awk '{ print $6 }'  )
echo "O valor de energia quântico eletrostico é $linha1"
linha2=$(grep "$string2" "$arquivoout" | awk '{ print $6 }'  )
echo "O valor de energia quântico de dispersão é $linha1"
linha3=$(grep "$string3" "$arquivoout" | awk '{ print $6 }'  )
echo "O valor de energia quântico de indução é $linha1"
linha4=$(echo "${linha1} + ${linha2} + ${linha3}" | bc)
echo "O valor de potencial de Van der Waals é $linha1"
echo "..."

modlinha=$(echo "sqrt(${linha1}*${linha1})" | bc)


if [[ $(echo "${modlinha} < ${parametro}" | bc ) -eq 1 ]] ;
then
    f=1
    echo "menor que $parametro fim do loop"
    echo "..."
    echo "..."
else
    echo "Valor de energia maior ou igual!"
    echo "Repetindo o loop"
    echo ". . ."
    echo ". . ."
fi

echo "$dist; $linha1; $linha2; $linha3; $linha4" >> $arquivoquant



#constantes do laço while
i=$(echo $i + 1 | bc)

dist=$(echo $dist + "$incr" | bc -l)

done

echo "Resultado ... (quantico e derivado)"
echo "arquivos disponíveis em $arquivoquant"
echo "..."
cat $arquivoquant
