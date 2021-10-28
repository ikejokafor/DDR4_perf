`ifndef __MEM_TRANSACTOR__
`define __MEM_TRANSACTOR__


class mem_transactor

    extern function new(virtual axi_intf _axi_intf);
    extern task axi_drvr(int id, string fn, virtual event start);

    virtual axi_intf m_axt_intf[];
    virtual event start;
endclass: mem_transactor


`endif