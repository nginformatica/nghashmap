set terminal png
set output 'benchmarks/png/get.png'
set title 'Benchmark [GET DATA]'
set key left top
set grid y
set ydata time
set timefmt '%s'
set ylabel 'seconds'
set xlabel 'elements'
set datafile separator ','
plot '/tmp/get-nghashmap.csv' using 0:1 smooth sbezier with lines title 'NGHashMap', \
     '/tmp/get-thashmap.csv' using 0:1 smooth sbezier with lines title 'THashMap', \
     '/tmp/get-ascan.csv' using 0:1 smooth sbezier with lines title 'aScan'
