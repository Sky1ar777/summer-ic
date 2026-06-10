vlib work
vmap work work
vlog ../sync_2ff.v
vlog ../sync2gray.v
vlog ../fifo_mem.v
vlog ../async_fifo.v
vlog ../tb/tb_async_fifo.v
vsim -voptargs=+acc work.tb_async_fifo
run -all
quit