-makelib ies_lib/xpm -sv \
  "/home/software/vivado-2019.2/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/home/software/vivado-2019.2/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/home/software/vivado-2019.2/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib ies_lib/axi_interconnect_v1_7_17 \
  "../../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../axi_interconnect/sim/axi_interconnect.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

