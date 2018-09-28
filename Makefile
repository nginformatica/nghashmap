benchmark:
	gnuplot benchmarks/put.gnu
	gnuplot benchmarks/get.gnu
	gnuplot benchmarks/arrays.gnu

harbour:
	hbmk2 nghashmap.hbp