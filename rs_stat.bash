#!/bin/bash

function get_prob {
  echo $1 | sed -rn "s/.*(\s|^)$2:([0-9\.]+).*/\2/p"
}


if [[ "${#@}" != "2" ]] || [[ ! "$1" =~ ^[01]$ ]] || [[ ! "$2" =~ ^[0-9][0-9]*$ ]] ; then
  echo "Use rs_stat.bash <algorithm> <n_samples>"
  echo "where <algorithm> is a random samplign algorithm"
  echo "  0 - with equal probabilty of all structures"
  echo "  1 - with equal probability of SIC structures"
  exit 1
fi

calc_p=`./rs_simul.bash $1 $2 | sed -r 's/.*w([0-9]+)\.cif/\1/g' | sort | uniq -c | awk -v NX=$2 '{print $2":"$1/NX}'`

echo ""

#Get probability of total structures
TS=`tar -tf rs_spinel.tar.gz | wc -l`
tot_p=`tar -tf rs_spinel.tar.gz | sed -r 's/.*w([0-9]+)\.cif/\1/g' | sort | uniq -c | awk -v NX=$TS '{print $2":"$1/NX}'`

echo ""

#Get probability of SIC structures
TS=`tar -tf rs_spinel.tar.gz | sed -r 's/.*w([0-9]+)\.cif/\1/g' | sort | uniq -c | awk '{print $1/$2}' | awk 'BEGIN{s=0}{s=s+$1}END{print s}'`
sic_p=`tar -tf rs_spinel.tar.gz | sed -r 's/.*w([0-9]+)\.cif/\1/g' | sort | uniq -c | awk -v NX=$TS '{print $2":"$1/NX/$2}'`

echo -e "Symmetry\tCalc\tSIC\tTotal"
for i in 6 12 24 48 96 192
do
  x=`get_prob "$calc_p" $i`
  if [[ "x$x" == "x" ]]; then
    x="0"
  fi
  echo -e "$i\t$x\t" `get_prob "$sic_p" $i` "\t" `get_prob "$tot_p" $i`
done




 
