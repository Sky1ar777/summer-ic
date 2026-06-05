vlib work
vmap work work
vlog ../uart_tx.v
vlog ../tb/tb_uart_tx_robust.v
vsim -voptargs=+acc work.tb_uart_tx_robust
run -all
quit