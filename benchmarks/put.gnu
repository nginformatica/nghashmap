set terminal png
set output 'benchmarks/png/put.png'
set title 'Benchmark [PUT DATA]'
set key left top
set grid y
set ydata time
set timefmt '%s'
set ylabel 'seconds'
set xlabel 'elements'
set datafile separator ','
plot '/tmp/put-nghashmap.csv' using 0:1 smooth sbezier with lines title 'NGHashMap', \
     '/tmp/put-thashmap.csv' using 0:1 smooth sbezier with lines title 'THashMap', \
     '/tmp/put-ascan.csv' using 0:1 smooth sbezier with lines title 'aScan'
