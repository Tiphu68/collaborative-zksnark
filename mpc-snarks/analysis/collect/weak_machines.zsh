#!/usr/bin/env zsh
trap "exit" INT TERM
trap "kill 0" EXIT

set -xe
if [ ! -f hosts ]; then
  ./analysis/collect/create_vms.zsh 24 1
fi
#log2sizes=(1 2 3 4 5)
#log2sizes=(1 2 3 4 5 6 7 8 9 10 11 12 13)
log2sizes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
proofs=(groth16 plonk marlin)
trials=3

(
# 2pc
parties=2
net=lan
for ps in ${proofs[@]}
do
  for t in $(seq 0 $(($trials - 1)))
  do
    for log2size in ${log2sizes[@]}
    do
      for alg in spdz
      do
        s=$((2 ** $log2size))
        echo $ps,$alg,$parties,$net,$s,$t
      done
    done
  done
done

# 3pc
parties=3
net=lan
for ps in ${proofs[@]}
do
  for t in $(seq 0 $(($trials - 1)))
  do
    for log2size in ${log2sizes[@]}
    do
      for alg in spdz gsz
      do
        s=$((2 ** $log2size))
        echo $ps,$alg,$parties,$net,$s,$t
      done
    done
  done
done

# 1pc
parties=1
net=cohost
for ps in ${proofs[@]}
do
  for t in $(seq 0 $(($trials - 1)))
  do
    for log2size in ${log2sizes[@]}
    do
      for alg in local
      do
        s=$((2 ** $log2size))
        echo $ps,$alg,$parties,$net,$s,$t
      done
    done
  done
done
) > benches

cat benches

./analysis/lib/runner.py hosts benches --output ./analysis/data/weak.csv

./analysis/collect/delete_vms.zsh
trap - INT TERM EXIT
