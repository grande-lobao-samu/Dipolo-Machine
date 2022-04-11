#!/bin/bash

# limpa os arquivos de execuções anteriores

#constantes do laço while principal
i=0
f=0

echo "Bem vindo ao calculador de dipolo 9000!"
echo "..."

if [ "$#" -ne 3 ]; then
    echo "Informe 3 parâmetros"
    echo "./exemplo1.sh distancia átomo carga"
    exit 2
fi
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


if [[ "$polar" == "1" ]];
then
    string="    Electrostatics          "
    dataarray=(1.855 1.080 1.820 1.850)
    echo "Dados de momento de dipolo obtidos de https://cccbdb.nist.gov/diplistx.asp"
    echo "..."
else
    string="    Induction          "
    dataarray=(1.710 1.160 4.610 2.448)
    echo "Dados de polarizabilidade obtidos de https://cccbdb.nist.gov/xp1x.asp?prop=9"
    echo "..."
fi

mkdir $nomeexp || echo "$nomeexp diretório já existe"
rm -f $nomeexp/*.out
rm -f $nomeexp/*.dat
rm -f $nomeexp/*.txt

arquivoquant=$(echo "$nomeexp/calculo_quantico_$nomeexp.txt")
arquivoderiv=$(echo "$nomeexp/calculo_derivado_$nomeexp.txt")

echo "Cálculos Quânticos de $string de $nomeexp" >> $arquivoquant
echo "Distância[Angstrom]; Energia[kJ/mol]" >> $arquivoquant

echo "Cálculos Derivados de $string de $nomeexp" >> $arquivoderiv
echo "Distância[Angstrom]; Energia[kJ/mol]" >> $arquivoderiv

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

arquivodat=$nomeexp/$nomeexp$dist.dat
arquivoout=$nomeexp/$nomeexp$dist.out

#coloca o cabecalho
cat >> $arquivodat << EOF 
molecule {
    0 1
EOF

#introduz primeira molecula no dat
cat base/$molecula.txt >> $arquivodat

cat >> $arquivodat << EOF
    --
    #ion
    $3 1
    $2                  0.00000000    0.00000000    $dist

    units angstrom
    no_reorient
    symmetry c1
}

set basis jun-cc-pvdz

energy('sapt0')
EOF

echo "escrevi $arquivodat"

psi4 "$arquivodat"
echo "rodei psi4 $arquivodat"

linha=$(grep "$string" "$arquivoout" | awk '{ print $6 }'  )
echo "O valor de energia quântico é $linha"
echo "..."

modlinha=$(echo "sqrt(${linha}*${linha})" | bc)

#################calculo derivado####################3

#constantesfisicas
fatordebye=`echo "3.336" | bc -l`
cargae=`echo "1.6" | bc -l`
permissividade=`echo "8.854" | bc -l`
avogrado=`echo "6.02" | bc -l`
sinal=$(echo "${linha}/${modlinha}" | bc -l | cut -c 1-2 )
sinalteste=$(echo "$sinal"| cut -c 1-2 )

carga=$(echo $3 | cut -c 2- )


#laço que verifica o tipo de cálculo de indução ou dipolo
if [[ $polar == 1 ]];
then
    echo "fazendo cálculo de íon dipolo"
    calc1=$(echo "${carga} * $cargae * ${dataarray[$nmolecula]} * $fatordebye" | bc -l)
    calc2=$(echo "${sinal} * $avogrado" | bc -l)
    calc3=$(echo "4 * 3.1415926535 * ${permissividade} * ${dist}^2" | bc -l)

    calcfim=$(echo "1000 * ${calc1} * ${calc2} / ${calc3}" | bc -l)
else
    echo "Fazendo cálculo íon dipolo induzido"
    calc1=$(echo "${carga}^2 * $cargae^2 * ${dataarray[$nmolecula]} * $avogrado" | bc -l)
    calc2=$(echo "4 * 3.1415926535 * ${permissividade} * ${dist}^4" | bc -l)
   
    calcfim=$(echo "10000 * ${calc1} * -1 / ${calc2}" | bc -l)
fi


echo "O cálculo de energia pela derivação resultou em $calcfim"
echo "..."

echo "$dist; $calcfim" >> $arquivoderiv

###################################################################


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

echo "$dist; $linha" >> $arquivoquant



#constantes do laço while
i=$(echo $i + 1 | bc)

dist=$(echo $dist + "$incr" | bc -l)

done

echo "Resultado ... (quantico e derivado)"
echo "arquivos disponíveis em $arquivoquant e $arquivoderiv"
echo "..."
cat $arquivoquant
echo "..."
cat $arquivoderiv
