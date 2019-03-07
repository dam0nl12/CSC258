vlib work
vlog -timescale 1ns/1ns tictachex.v
vsim tictachex
log {/*}
add wave {/*}

force {SW[0]} 0 0, 1 10 -r 20
force {SW[1]} 0 0, 1 20 -r 40
force {SW[2]} 0 0, 1 40 -r 80
force {SW[3]} 0 0, 1 80 -r 160

run 360 ns