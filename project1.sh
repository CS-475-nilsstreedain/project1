#!/bin/bash

/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=1 -DNUMTRIALS=50000 -DCSV=true project1.cpp -o project1 && ./project1
/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=2 -DNUMTRIALS=50000 -DCSV=true project1.cpp -o project1 && ./project1
/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=4 -DNUMTRIALS=50000 -DCSV=true project1.cpp -o project1 && ./project1
/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=6 -DNUMTRIALS=50000 -DCSV=true project1.cpp -o project1 && ./project1
/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=8 -DNUMTRIALS=50000 -DCSV=true project1.cpp -o project1 && ./project1

/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=4 -DNUMTRIALS=50000 -DCSV=true project1.cpp -o project1 && ./project1
/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=4 -DNUMTRIALS=100000 -DCSV=true project1.cpp -o project1 && ./project1
/opt/homebrew/opt/llvm/bin/clang++ -Xpreprocessor -fopenmp -I/opt/homebrew/opt/llvm/include -L/opt/homebrew/opt/llvm/lib -lomp -DNUMT=4 -DNUMTRIALS=500000 -DCSV=true project1.cpp -o project1 && ./project1
