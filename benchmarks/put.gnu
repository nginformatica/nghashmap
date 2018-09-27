set terminal png
set output 'benchmarks/png/put.png'
set title 'Benchmark [PUT DATA]'
set key left top
set grid y
set ylabel 'ms'
set xlabel 'elements'
set datafile separator ','
plot '/tmp/put-nghashmap.csv' using 0:($1*1000) smooth sbezier with lines title 'NGHashMap', \
     '/tmp/put-thashmap.csv' using 0:($1*1000) smooth sbezier with lines title 'THashMap', \
     '/tmp/put-ascan.csv' using 0:($1*1000) smooth sbezier with lines title 'aScan'
