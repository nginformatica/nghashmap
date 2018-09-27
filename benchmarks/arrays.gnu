set terminal png
set output 'benchmarks/png/arrays.png'
set title '3 levels, aScan, worst case'
set key left top
set grid y
set ylabel 'time'
set xlabel 'n'
set datafile separator ','

set xrange [1:10]

h(x) = x + log(x)
a(x) = x ** 3

plot h(x) title 'HashMap ≈ O(1)', \
     a(x) title 'aScan O(n³)'
