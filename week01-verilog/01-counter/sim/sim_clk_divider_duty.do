vlib work
vmap work work
vlog ../clk_divider_duty.v
vlog ../tb/tb_clk_divider_duty.v
vsim -voptargs=+acc work.tb_clk_divider_duty
add wave /tb_clk_divider_duty/*
run 2000ns
