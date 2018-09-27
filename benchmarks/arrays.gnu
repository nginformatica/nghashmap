set terminal png
set output 'benchmarks/png/arrays.png'
set title '3 levels, aScan, worst case'
set key left top
set grid y
set ylabel 'time'
set xlabel 'n'
set datafile separator ','

plot '/tmp/get-ascan.csv' using 0:($2 ** 3) smooth sbezier with lines title 'aScan'
