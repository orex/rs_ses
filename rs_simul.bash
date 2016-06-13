#!/bin/bash

#File "rs_spinel.tar.gz" contains 12870 derivative structures for MgAl_{1.0}Fe_{1.0}O_4 spinel cell 1x1x1
#The program is taken randomly structure from the archive, simulating random sampling algorithm.

function get_random_str {
  shuf -n 1 $1 
}

if [[ "${#@}" != "2" ]] || [[ ! "$1" =~ ^[01]$ ]] || [[ ! "$2" =~ ^[0-9][0-9]*$ ]] ; then
  echo "Use rs_simul.bash <algorithm> <n_samples>"
  echo "where <algorithm> is a random samplign algorithm"
  echo "  0 - with equal probabilty of all structures"
  echo "  1 - with equal probability of SIC structures"
  exit 1
fi

tmpf=`tempfile`
tar -tf rs_spinel.tar.gz > $tmpf

if [[ $1 == "0" ]]; then
  for ((i=0;i<$2;i++))
  do
    # Classical random samplng
    get_random_str $tmpf
  done
else
  for ((i=0;i<$2;i++))
  do
    # Improved RS
    while true
    do
      x=`get_random_str $tmpf`
      w=`echo $x | sed -r 's/.*w([0-9]+)\.cif/\1/g' | awk '{print $1/6}'`
      let "pb=$RANDOM%$w"
      if [[ "$pb" == "0" ]]; then
        echo $x
        break
      fi
    done
  done
fi  
