do compile.do
do elaborate.do

vsim -t 1ps -lib xil_defaultlib sim_tb_top_opt

run -all
