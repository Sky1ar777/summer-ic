vlib work
vmap work work

vlog ../uart_tx.v
vlog ../tb/tb_uart_tx.v

vsim -voptargs=+acc work.tb_uart_tx

run -all
