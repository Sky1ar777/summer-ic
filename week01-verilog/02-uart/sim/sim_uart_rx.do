vlib work
vmap work work
vlog ../uart_rx.v
vlog ../tb/tb_uart_rx.v
vsim -voptargs=+acc work.tb_uart_rx
run 50000ns
quit