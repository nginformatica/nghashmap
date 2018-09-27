set terminal png
set output 'benchmarks/png/get.png'
set title 'Benchmark [GET DATA]'
set key left top
set grid y
set ylabel 'ms'
set xlabel 'elements'
set datafile separator ','
plot '/tmp/get-nghashmap.csv' using 0:($2*1000) smooth sbezier with lines title 'NGHashMap', \
     '/tmp/get-thashmap.csv' using 0:($1*1000) smooth sbezier with lines title 'THashMap', \
     '/tmp/get-ascan.csv' using 0:($1*1000) smooth sbezier with lines title 'aScan'
