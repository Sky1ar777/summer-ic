vlib work
vmap work work
vlog ../uart_tx.v
vlog ../uart_rx.v
vlog ../uart_top.v
vlog ../tb/tb_uart_top.v
vsim -voptargs=+acc work.tb_uart_top
run -all
quit