#!/bin/bash

# Define arrays for NUMT and NUMTRIALS values
NUMT_VALUES=(1 2 4 6 8)
NUMTRIALS_VALUES=(50000 100000 500000)

# Compiler and flags
CLANG="/opt/homebrew/opt/llvm/bin/clang++"
FLAGS="-Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DCSV=true"

# Loop over NUMT and NUMTRIALS combinations
for NUMT in "${NUMT_VALUES[@]}"; do
  for NUMTRIALS in "${NUMTRIALS_VALUES[@]}"; do
    $CLANG $FLAGS -DNUMT=$NUMT -DNUMTRIALS=$NUMTRIALS project1.cpp -o project1
    ./project1
  done
done
