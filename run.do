vlib work
vlog *.v*
vsim -voptargs=+acc work.tb
add wave *
run -all
