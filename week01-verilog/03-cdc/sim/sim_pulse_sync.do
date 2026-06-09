vlib work
vmap work work
vlog ../pulse_sync.v
vlog ../tb/tb_pulse_sync.v
vsim -voptargs=+acc work.tb_pulse_sync
add wave /tb_pulse_sync/*
run 2000ns