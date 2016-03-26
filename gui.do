vlib work 
vlog gui.v
vsim controlgui

log -r {/*}
add wave {/*} 

force {clk} 0 0, 1 5 -r 10
force {resetn} 0 0, 1 7

