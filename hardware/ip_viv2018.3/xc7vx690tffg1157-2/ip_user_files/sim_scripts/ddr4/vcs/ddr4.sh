#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2018.3 (64-bit)
#
# Filename    : ddr4.sh
# Simulator   : Synopsys Verilog Compiler Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Thu Oct 28 18:08:53 EDT 2021
# SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved. 
#
# usage: ddr4.sh [-help]
# usage: ddr4.sh [-lib_map_path]
# usage: ddr4.sh [-noclean_files]
# usage: ddr4.sh [-reset_run]
#
# Prerequisite:- To compile and run simulation, you must compile the Xilinx simulation libraries using the
# 'compile_simlib' TCL command. For more information about this command, run 'compile_simlib -help' in the
# Vivado Tcl Shell. Once the libraries have been compiled successfully, specify the -lib_map_path switch
# that points to these libraries and rerun export_simulation. For more information about this switch please
# type 'export_simulation -help' in the Tcl shell.
#
# You can also point to the simulation libraries by either replacing the <SPECIFY_COMPILED_LIB_PATH> in this
# script with the compiled library directory path or specify this path with the '-lib_map_path' switch when
# executing this script. Please type 'ddr4.sh -help' for more information.
#
# Additional references - 'Xilinx Vivado Design Suite User Guide:Logic simulation (UG900)'
#
#*********************************************************************************************************

# Directory path for design sources and include directories (if any) wrt this path
ref_dir="."

# Override directory with 'export_sim_ref_dir' env path value if set in the shell
if [[ (! -z "$export_sim_ref_dir") && ($export_sim_ref_dir != "") ]]; then
  ref_dir="$export_sim_ref_dir"
fi

# Command line options
vlogan_opts="-full64"
vhdlan_opts="-full64"
vcs_elab_opts="-full64 -debug_pp -t ps -licqueue -l elaborate.log"
vcs_sim_opts="-ucli -licqueue -l simulate.log"

# Design libraries
design_libs=(xil_defaultlib xpm microblaze_v11_0_0 lib_cdc_v1_0_2 proc_sys_reset_v5_0_13 lmb_v10_v3_0_9 lmb_bram_if_cntlr_v4_0_15 blk_mem_gen_v8_4_2 iomodule_v3_1_4)

# Simulation root library directory
sim_lib_dir="vcs_lib"

# Script info
echo -e "ddr4.sh - Script generated by export_simulation (Vivado v2018.3 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $1
  setup $1 $2
  compile
  elaborate
  simulate
}

# RUN_STEP: <compile>
compile()
{
  # Compile design files
  vlogan -work xil_defaultlib $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../ddr4/ip_1/rtl/map" +incdir+"$ref_dir/../../../../ddr4/rtl/ip_top" +incdir+"$ref_dir/../../../../ddr4/rtl/cal" \
    "/home/software/vivado-2018.3/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
  2>&1 | tee -a vlogan.log

  vhdlan -work xpm $vhdlan_opts \
    "/home/software/vivado-2018.3/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work microblaze_v11_0_0 $vhdlan_opts \
    "$ref_dir/../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_0/sim/bd_c703_microblaze_I_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_cdc_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work proc_sys_reset_v5_0_13 $vhdlan_opts \
    "$ref_dir/../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_1/sim/bd_c703_rst_0_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lmb_v10_v3_0_9 $vhdlan_opts \
    "$ref_dir/../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_2/sim/bd_c703_ilmb_0.vhd" \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_3/sim/bd_c703_dlmb_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lmb_bram_if_cntlr_v4_0_15 $vhdlan_opts \
    "$ref_dir/../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_4/sim/bd_c703_dlmb_cntlr_0.vhd" \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_5/sim/bd_c703_ilmb_cntlr_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work blk_mem_gen_v8_4_2 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../ddr4/ip_1/rtl/map" +incdir+"$ref_dir/../../../../ddr4/rtl/ip_top" +incdir+"$ref_dir/../../../../ddr4/rtl/cal" \
    "$ref_dir/../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../ddr4/ip_1/rtl/map" +incdir+"$ref_dir/../../../../ddr4/rtl/ip_top" +incdir+"$ref_dir/../../../../ddr4/rtl/cal" \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_6/sim/bd_c703_lmb_bram_I_0.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_7/sim/bd_c703_second_dlmb_cntlr_0.vhd" \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_8/sim/bd_c703_second_ilmb_cntlr_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../ddr4/ip_1/rtl/map" +incdir+"$ref_dir/../../../../ddr4/rtl/ip_top" +incdir+"$ref_dir/../../../../ddr4/rtl/cal" \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_9/sim/bd_c703_second_lmb_bram_I_0.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work iomodule_v3_1_4 $vhdlan_opts \
    "$ref_dir/../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../../ddr4/bd_0/ip/ip_10/sim/bd_c703_iomodule_0_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../ddr4/ip_1/rtl/map" +incdir+"$ref_dir/../../../../ddr4/rtl/ip_top" +incdir+"$ref_dir/../../../../ddr4/rtl/cal" \
    "$ref_dir/../../../../ddr4/bd_0/sim/bd_c703.v" \
    "$ref_dir/../../../../ddr4/ip_0/sim/ddr4_microblaze_mcs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../ddr4/ip_1/rtl/map" +incdir+"$ref_dir/../../../../ddr4/rtl/ip_top" +incdir+"$ref_dir/../../../../ddr4/rtl/cal" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/phy/ddr4_phy_ddr4.sv" \
    "$ref_dir/../../../../ddr4/ip_1/rtl/ip_top/ddr4_phy.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_wtr.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ref.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_rd_wr.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_periodic.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_group.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ecc.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_ctl.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_arb_p.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_arb_c.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_arb_a.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_act_timer.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc_act_rank.sv" \
    "$ref_dir/../../../../ddr4/rtl/controller/ddr4_v2_2_mc.sv" \
    "$ref_dir/../../../../ddr4/rtl/ui/ddr4_v2_2_ui_wr_data.sv" \
    "$ref_dir/../../../../ddr4/rtl/ui/ddr4_v2_2_ui_rd_data.sv" \
    "$ref_dir/../../../../ddr4/rtl/ui/ddr4_v2_2_ui_cmd.sv" \
    "$ref_dir/../../../../ddr4/rtl/ui/ddr4_v2_2_ui.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_ar_channel.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_aw_channel.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_b_channel.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_cmd_arbiter.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_cmd_fsm.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_cmd_translator.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_fifo.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_incr_cmd.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_r_channel.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_w_channel.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_wr_cmd_fsm.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_wrap_cmd.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_a_upsizer.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_register_slice.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axi_upsizer.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_axic_register_slice.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_carry_and.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_carry_latch_and.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_carry_latch_or.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_carry_or.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_command_fifo.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_comparator.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_comparator_sel.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_comparator_sel_static.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_r_upsizer.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi/ddr4_v2_2_w_upsizer.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_addr_decode.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_read.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg_bank.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_top.sv" \
    "$ref_dir/../../../../ddr4/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_write.sv" \
    "$ref_dir/../../../../ddr4/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_write.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_sync.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_read.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_pi.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_top.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_cal.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
    "$ref_dir/../../../../ddr4/rtl/ip_top/ddr4.sv" \
    "$ref_dir/../../../../ddr4/rtl/ip_top/ddr4_ddr4.sv" \
    "$ref_dir/../../../../ddr4/rtl/ip_top/ddr4_ddr4_mem_intfc.sv" \
    "$ref_dir/../../../../ddr4/rtl/cal/ddr4_ddr4_cal_riu.sv" \
    "$ref_dir/../../../../ddr4/tb/microblaze_mcs_0.sv" \
  2>&1 | tee -a vlogan.log


  vlogan -work xil_defaultlib $vlogan_opts +v2k \
    glbl.v \
  2>&1 | tee -a vlogan.log

}

# RUN_STEP: <elaborate>
elaborate()
{
  vcs $vcs_elab_opts xil_defaultlib.ddr4 xil_defaultlib.glbl -o ddr4_simv
}

# RUN_STEP: <simulate>
simulate()
{
  ./ddr4_simv $vcs_sim_opts -do simulate.do
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./ddr4.sh -help\" for more information)\n"
        exit 1
      fi
      create_lib_mappings $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
      create_lib_mappings $2
  esac

  create_lib_dir

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Define design library mappings
create_lib_mappings()
{
  file="synopsys_sim.setup"
  if [[ -e $file ]]; then
    if [[ ($1 == "") ]]; then
      return
    else
      rm -rf $file
    fi
  fi

  touch $file

  lib_map_path="<SPECIFY_COMPILED_LIB_PATH>"
  if [[ ($1 != "" && -e $1) ]]; then
    lib_map_path="$1"
  else
    echo -e "ERROR: Compiled simulation library directory path not specified or does not exist (type "./top.sh -help" for more information)\n"
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    mapping="$lib:$sim_lib_dir/$lib"
    echo $mapping >> $file
  done

  if [[ ($lib_map_path != "") ]]; then
    incl_ref="OTHERS=$lib_map_path/synopsys_sim.setup"
    echo $incl_ref >> $file
  fi
}

# Create design library directory paths
create_lib_dir()
{
  if [[ -e $sim_lib_dir ]]; then
    rm -rf $sim_lib_dir
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    lib_dir="$sim_lib_dir/$lib"
    if [[ ! -e $lib_dir ]]; then
      mkdir -p $lib_dir
    fi
  done
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(ucli.key ddr4_simv vlogan.log vhdlan.log compile.log elaborate.log simulate.log .vlogansetup.env .vlogansetup.args .vcs_lib_lock scirocco_command.log 64 AN.DB csrc ddr4_simv.daidir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done

  create_lib_dir
}

# Check command line arguments
check_args()
{
  if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$2' (type \"./ddr4.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: ddr4.sh [-help]\n\
Usage: ddr4.sh [-lib_map_path]\n\
Usage: ddr4.sh [-reset_run]\n\
Usage: ddr4.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2
