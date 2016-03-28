vlib work 
vlog gui.v
vsim datapathgui -gFIRST_DIVIDER=2 -gSECOND_DIVIDER=4 -gTHIRD_DIVIDER=6

log -r {/*}
add wave {/*}

force {clock} 0 0, 1 5 -r 10
force {reset} 0 0, 1 7 
force {redraw} 1
force {keys_pressed[3:0]} 2#0001
force {clock_count[14:0]} 2#000000000000000 10, 2#000000000000001 24, 2#000000000000010 34, 2#000000000000011 44, 2#000000000000100 54, 2#000000000000101 64 
run 70ns
