#Pin LOC constraints for the status signals init_calib_complete and data_compare_error

#LOC constraints provided if the pins are selected for status signals

set_property PACKAGE_PIN AV20 [ get_ports "c0_data_compare_error" ]
set_property IOSTANDARD LVCMOS12 [ get_ports "c0_data_compare_error" ]

set_property DRIVE 8 [ get_ports "c0_data_compare_error" ]

set_property PACKAGE_PIN AW20 [ get_ports "c0_init_calib_complete" ]
set_property IOSTANDARD LVCMOS12 [ get_ports "c0_init_calib_complete" ]

set_property DRIVE 8 [ get_ports "c0_init_calib_complete" ]

set_property PACKAGE_PIN AY20 [ get_ports "sys_rst" ]
set_property IOSTANDARD LVCMOS12 [ get_ports "sys_rst" ]

set_property PACKAGE_PIN BB18 [ get_ports "c0_sys_clk_p" ]
set_property IOSTANDARD DIFF_SSTL12 [ get_ports "c0_sys_clk_p" ]

set_property PACKAGE_PIN BC18 [ get_ports "c0_sys_clk_n" ]
set_property IOSTANDARD DIFF_SSTL12 [ get_ports "c0_sys_clk_n" ]

set_property PACKAGE_PIN AV15 [ get_ports "c0_ddr4_dq[7]" ]
set_property PACKAGE_PIN AV16 [ get_ports "c0_ddr4_dq[6]" ]
set_property PACKAGE_PIN AV22 [ get_ports "c0_ddr4_dm_dbi_n[1]" ]
set_property PACKAGE_PIN AV25 [ get_ports "c0_ddr4_dq[14]" ]
set_property PACKAGE_PIN AV26 [ get_ports "c0_ddr4_dq[38]" ]
set_property PACKAGE_PIN AV27 [ get_ports "c0_ddr4_dq[39]" ]
set_property PACKAGE_PIN AV28 [ get_ports "c0_ddr4_dqs_t[4]" ]
set_property PACKAGE_PIN AV31 [ get_ports "c0_ddr4_dq[62]" ]
set_property PACKAGE_PIN AV32 [ get_ports "c0_ddr4_dq[63]" ]
set_property PACKAGE_PIN AV33 [ get_ports "c0_ddr4_dqs_t[8]" ]
set_property PACKAGE_PIN AV35 [ get_ports "c0_ddr4_dq[70]" ]
set_property PACKAGE_PIN AV36 [ get_ports "c0_ddr4_dq[71]" ]
set_property PACKAGE_PIN AW14 [ get_ports "c0_ddr4_dq[5]" ]
set_property PACKAGE_PIN AW15 [ get_ports "c0_ddr4_dq[4]" ]
set_property PACKAGE_PIN AW23 [ get_ports "c0_ddr4_dq[8]" ]
set_property PACKAGE_PIN AW24 [ get_ports "c0_ddr4_dq[9]" ]
set_property PACKAGE_PIN AW25 [ get_ports "c0_ddr4_dq[15]" ]
set_property PACKAGE_PIN AW28 [ get_ports "c0_ddr4_dqs_c[4]" ]
set_property PACKAGE_PIN AW29 [ get_ports "c0_ddr4_dq[58]" ]
set_property PACKAGE_PIN AW30 [ get_ports "c0_ddr4_dq[60]" ]
set_property PACKAGE_PIN AW33 [ get_ports "c0_ddr4_dqs_c[8]" ]
set_property PACKAGE_PIN AW34 [ get_ports "c0_ddr4_dq[64]" ]
set_property PACKAGE_PIN AW35 [ get_ports "c0_ddr4_dq[65]" ]
set_property PACKAGE_PIN AY14 [ get_ports "c0_ddr4_dqs_t[0]" ]
set_property PACKAGE_PIN AY15 [ get_ports "c0_ddr4_dq[3]" ]
set_property PACKAGE_PIN AY16 [ get_ports "c0_ddr4_dq[2]" ]
set_property PACKAGE_PIN AY19 [ get_ports "c0_ddr4_cs_n[0]" ]
set_property PACKAGE_PIN AY21 [ get_ports "c0_ddr4_reset_n" ]
set_property PACKAGE_PIN AY22 [ get_ports "c0_ddr4_dq[10]" ]
set_property PACKAGE_PIN AY25 [ get_ports "c0_ddr4_dm_dbi_n[4]" ]
set_property PACKAGE_PIN AY26 [ get_ports "c0_ddr4_dq[36]" ]
set_property PACKAGE_PIN AY27 [ get_ports "c0_ddr4_dq[37]" ]
set_property PACKAGE_PIN AY29 [ get_ports "c0_ddr4_dq[59]" ]
set_property PACKAGE_PIN AY30 [ get_ports "c0_ddr4_dq[61]" ]
set_property PACKAGE_PIN AY31 [ get_ports "c0_ddr4_dm_dbi_n[7]" ]
set_property PACKAGE_PIN AY32 [ get_ports "c0_ddr4_dm_dbi_n[8]" ]
set_property PACKAGE_PIN AY34 [ get_ports "c0_ddr4_dq[66]" ]
set_property PACKAGE_PIN AY36 [ get_ports "c0_ddr4_dq[68]" ]
set_property PACKAGE_PIN BA14 [ get_ports "c0_ddr4_dqs_c[0]" ]
set_property PACKAGE_PIN BA16 [ get_ports "c0_ddr4_dq[0]" ]
set_property PACKAGE_PIN BA17 [ get_ports "c0_ddr4_act_n" ]
set_property PACKAGE_PIN BA18 [ get_ports "c0_ddr4_odt[0]" ]
set_property PACKAGE_PIN BA19 [ get_ports "c0_ddr4_cke[0]" ]
set_property PACKAGE_PIN BA21 [ get_ports "c0_ddr4_adr[14]" ]
set_property PACKAGE_PIN BA22 [ get_ports "c0_ddr4_dq[11]" ]
set_property PACKAGE_PIN BA23 [ get_ports "c0_ddr4_dqs_t[1]" ]
set_property PACKAGE_PIN BA24 [ get_ports "c0_ddr4_dq[12]" ]
set_property PACKAGE_PIN BA27 [ get_ports "c0_ddr4_dq[32]" ]
set_property PACKAGE_PIN BA28 [ get_ports "c0_ddr4_dq[33]" ]
set_property PACKAGE_PIN BA29 [ get_ports "c0_ddr4_dqs_t[7]" ]
set_property PACKAGE_PIN BA33 [ get_ports "c0_ddr4_dq[54]" ]
set_property PACKAGE_PIN BA34 [ get_ports "c0_ddr4_dq[67]" ]
set_property PACKAGE_PIN BA36 [ get_ports "c0_ddr4_dq[69]" ]
set_property PACKAGE_PIN BB15 [ get_ports "c0_ddr4_dm_dbi_n[0]" ]
set_property PACKAGE_PIN BB16 [ get_ports "c0_ddr4_dq[1]" ]
set_property PACKAGE_PIN BB19 [ get_ports "c0_ddr4_bg[0]" ]
set_property PACKAGE_PIN BB20 [ get_ports "c0_ddr4_ba[1]" ]
set_property PACKAGE_PIN BB21 [ get_ports "c0_ddr4_adr[15]" ]
set_property PACKAGE_PIN BB23 [ get_ports "c0_ddr4_dqs_c[1]" ]
set_property PACKAGE_PIN BB24 [ get_ports "c0_ddr4_dq[13]" ]
set_property PACKAGE_PIN BB25 [ get_ports "c0_ddr4_dm_dbi_n[3]" ]
set_property PACKAGE_PIN BB28 [ get_ports "c0_ddr4_dq[34]" ]
set_property PACKAGE_PIN BB29 [ get_ports "c0_ddr4_dqs_c[7]" ]
set_property PACKAGE_PIN BB30 [ get_ports "c0_ddr4_dq[56]" ]
set_property PACKAGE_PIN BB31 [ get_ports "c0_ddr4_dq[57]" ]
set_property PACKAGE_PIN BB33 [ get_ports "c0_ddr4_dq[55]" ]
set_property PACKAGE_PIN BB34 [ get_ports "c0_ddr4_dqs_t[6]" ]
set_property PACKAGE_PIN BB35 [ get_ports "c0_ddr4_dqs_c[6]" ]
set_property PACKAGE_PIN BB36 [ get_ports "c0_ddr4_dq[50]" ]
set_property PACKAGE_PIN BC16 [ get_ports "c0_ddr4_adr[9]" ]
set_property PACKAGE_PIN BC17 [ get_ports "c0_ddr4_adr[8]" ]
set_property PACKAGE_PIN BC20 [ get_ports "c0_ddr4_ba[0]" ]
set_property PACKAGE_PIN BC21 [ get_ports "c0_ddr4_adr[16]" ]
set_property PACKAGE_PIN BC22 [ get_ports "c0_ddr4_dm_dbi_n[2]" ]
set_property PACKAGE_PIN BC25 [ get_ports "c0_ddr4_dq[22]" ]
set_property PACKAGE_PIN BC26 [ get_ports "c0_ddr4_dq[24]" ]
set_property PACKAGE_PIN BC27 [ get_ports "c0_ddr4_dq[25]" ]
set_property PACKAGE_PIN BC28 [ get_ports "c0_ddr4_dq[35]" ]
set_property PACKAGE_PIN BC30 [ get_ports "c0_ddr4_dq[46]" ]
set_property PACKAGE_PIN BC31 [ get_ports "c0_ddr4_dqs_t[5]" ]
set_property PACKAGE_PIN BC32 [ get_ports "c0_ddr4_dq[52]" ]
set_property PACKAGE_PIN BC33 [ get_ports "c0_ddr4_dq[53]" ]
set_property PACKAGE_PIN BC35 [ get_ports "c0_ddr4_dq[48]" ]
set_property PACKAGE_PIN BC36 [ get_ports "c0_ddr4_dq[51]" ]
set_property PACKAGE_PIN BD15 [ get_ports "c0_ddr4_adr[6]" ]
set_property PACKAGE_PIN BD17 [ get_ports "c0_ddr4_ck_c[0]" ]
set_property PACKAGE_PIN BD18 [ get_ports "c0_ddr4_ck_t[0]" ]
set_property PACKAGE_PIN BD19 [ get_ports "c0_ddr4_adr[13]" ]
set_property PACKAGE_PIN BD20 [ get_ports "c0_ddr4_adr[12]" ]
set_property PACKAGE_PIN BD22 [ get_ports "c0_ddr4_dq[18]" ]
set_property PACKAGE_PIN BD23 [ get_ports "c0_ddr4_dq[20]" ]
set_property PACKAGE_PIN BD24 [ get_ports "c0_ddr4_dq[21]" ]
set_property PACKAGE_PIN BD25 [ get_ports "c0_ddr4_dq[23]" ]
set_property PACKAGE_PIN BD27 [ get_ports "c0_ddr4_dq[28]" ]
set_property PACKAGE_PIN BD28 [ get_ports "c0_ddr4_dq[29]" ]
set_property PACKAGE_PIN BD29 [ get_ports "c0_ddr4_dq[44]" ]
set_property PACKAGE_PIN BD30 [ get_ports "c0_ddr4_dq[47]" ]
set_property PACKAGE_PIN BD32 [ get_ports "c0_ddr4_dqs_c[5]" ]
set_property PACKAGE_PIN BD35 [ get_ports "c0_ddr4_dq[49]" ]
set_property PACKAGE_PIN BE15 [ get_ports "c0_ddr4_adr[7]" ]
set_property PACKAGE_PIN BE16 [ get_ports "c0_ddr4_adr[5]" ]
set_property PACKAGE_PIN BE17 [ get_ports "c0_ddr4_adr[4]" ]
set_property PACKAGE_PIN BE20 [ get_ports "c0_ddr4_adr[11]" ]
set_property PACKAGE_PIN BE21 [ get_ports "c0_ddr4_adr[10]" ]
set_property PACKAGE_PIN BE22 [ get_ports "c0_ddr4_dq[19]" ]
set_property PACKAGE_PIN BE24 [ get_ports "c0_ddr4_dqs_t[2]" ]
set_property PACKAGE_PIN BE25 [ get_ports "c0_ddr4_dqs_c[2]" ]
set_property PACKAGE_PIN BE26 [ get_ports "c0_ddr4_dq[26]" ]
set_property PACKAGE_PIN BE27 [ get_ports "c0_ddr4_dqs_t[3]" ]
set_property PACKAGE_PIN BE29 [ get_ports "c0_ddr4_dq[30]" ]
set_property PACKAGE_PIN BE30 [ get_ports "c0_ddr4_dq[45]" ]
set_property PACKAGE_PIN BE31 [ get_ports "c0_ddr4_dq[42]" ]
set_property PACKAGE_PIN BE32 [ get_ports "c0_ddr4_dq[43]" ]
set_property PACKAGE_PIN BE34 [ get_ports "c0_ddr4_dm_dbi_n[6]" ]
set_property PACKAGE_PIN BF16 [ get_ports "c0_ddr4_adr[1]" ]
set_property PACKAGE_PIN BF17 [ get_ports "c0_ddr4_adr[0]" ]
set_property PACKAGE_PIN BF18 [ get_ports "c0_ddr4_adr[3]" ]
set_property PACKAGE_PIN BF19 [ get_ports "c0_ddr4_adr[2]" ]
set_property PACKAGE_PIN BF21 [ get_ports "c0_ddr4_bg[1]" ]
set_property PACKAGE_PIN BF23 [ get_ports "c0_ddr4_dq[16]" ]
set_property PACKAGE_PIN BF24 [ get_ports "c0_ddr4_dq[17]" ]
set_property PACKAGE_PIN BF26 [ get_ports "c0_ddr4_dq[27]" ]
set_property PACKAGE_PIN BF27 [ get_ports "c0_ddr4_dqs_c[3]" ]
set_property PACKAGE_PIN BF29 [ get_ports "c0_ddr4_dq[31]" ]
set_property PACKAGE_PIN BF31 [ get_ports "c0_ddr4_dm_dbi_n[5]" ]
set_property PACKAGE_PIN BF33 [ get_ports "c0_ddr4_dq[40]" ]
set_property PACKAGE_PIN BF34 [ get_ports "c0_ddr4_dq[41]" ]

