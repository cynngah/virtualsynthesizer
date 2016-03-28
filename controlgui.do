vlib work 
vlog gui.v
vsim controlgui -gPIXEL_COUNT=3

log -r {/*}
add wave {/*} 

force {clock} 0 0, 1 5 -r 10
force {reset} 0 0, 1 7 
force {keys[3:0]} 2#0001 

run 80ns

