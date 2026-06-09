vlib work
vmap work work
vlog ../sync_2ff.v
vlog ../tb/tb_sync_2ff.v
vsim -voptargs=+acc work.tb_sync_2ff
add wave /tb_sync_2ff/*
run 2000ns