`include "mem_transactor.svh"


function mem_transactor::new(virtual axi_intf _axi_intf[])
    m_axt_intf = _axi_intf
endfunction: new


task mem_transactor::axi_drvr(int id, string fn, virtual event start);
    wait(start.triggered);
endtask: axi_drvr
