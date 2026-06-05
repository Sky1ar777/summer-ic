vlib work
vmap work work

vlog ../counter.v
vlog ../tb/tb_counter.v

vsim -voptargs=+acc work.tb_counter   
add wave /tb_counter/*                

run 2000ns
