vlib work
vlog -timescale 1ns/1ns shift_test.v
vsim shift_test
log {/*}
add wave {/*}

force {CLOCK_50} 0 0, 1 1 -r 2
force {SW[9]} 1; force {KEY[0]} 1; force {KEY[1]} 1; force {KEY[3]} 1
run 10 ns
force {SW[9]} 0; force {KEY[0]} 0;
run 10 ns

force {KEY[1]} 0
run 5 ns
force {KEY[3]} 0
run 5 ns

force {KEY[0]} 1; force {KEY[1]} 1; force {KEY[3]} 1
run 5 ns

force {KEY[1]} 0
run 5 ns

force {KEY[3]} 1
run 5ns

force {KEY[3]} 0
run 5ns

force {SW[0]} 1
run 20 ns

#force {KEY[0]} 0 0, 1 10 -r 20
#force {KEY[1]} 0 0, 1 5 -r 10
#force {KEY[3]} 1 0, 0 15 -r 30

run 500000000 ns 

