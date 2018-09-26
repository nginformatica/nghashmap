set terminal png
set output 'benchmarks/result.png'
set title 'Benchmark'
set key left top
set grid y
set ydata time
set timefmt '%s'
set ylabel 'seconds'
set xlabel 'elements'
set datafile separator ','
plot '/tmp/nghashmap.csv' using 0:1 smooth sbezier with lines title 'NGHashMap', \
     '/tmp/thashmap.csv' using 0:1 smooth sbezier with lines title 'THashMap'
