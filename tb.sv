
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item ;
  
  rand bit din;
  bit dout;
  
  function new(string path="transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(din,UVM_DEFAULT)
  `uvm_field_int(dout,UVM_DEFAULT)
  `uvm_object_utils_end
  
endclass

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  transaction t ;
  
  function new(string path="generator");
    super.new(path);
  endfunction
  
  virtual task body();
    t=transaction::type_id::create("t");
    repeat(10)
      begin
        start_item(t);
        t.randomize();
        `uvm_info("GEN",$sformatf("Data send to Driver din :%0d ",t.din), UVM_NONE);  
        finish_item(t);
      end
  endtask 
  
endclass

class driver extends uvm_driver #(transaction);
  
  `uvm_component_utils(driver);
  transaction t ;
  virtual ff aif ;
  
  function new(string path="driver",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  task reset_dut();
    aif.rst<=1'b1;
    aif.din<=0;
    repeat(5)@(posedge aif.clk);
    aif.rst<=0 ;
    `uvm_info("DRV","RESET DONE",UVM_NONE);
  endtask
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t=transaction::type_id::create("t");
    if(!uvm_config_db#(virtual ff)::get(this,"","aif",aif))
      `uvm_error("DRV","unable to access uvm_config_db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    reset_dut();
    forever begin 
      seq_item_port.get_next_item(t);
      aif.din<=t.din;
      seq_item_port.item_done();
      `uvm_info("GEN",$sformatf("Data send to DUT din :%0d ",t.din), UVM_NONE); 
      @(posedge aif.clk);
      @(posedge aif.clk);
    end
  endtask 
endclass
  
class monitor extends uvm_monitor;
  
  `uvm_component_utils(monitor)
   uvm_analysis_port#(transaction) send ;
  transaction t ;
  virtual ff aif ;
  
  function new(string path="monitor",uvm_component parent=null);
    super.new(path,parent);
  endfunction 
 
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
    t=transaction::type_id::create("trans");
    if(!uvm_config_db#(virtual ff )::get(this,"","aif",aif))
      `uvm_error("MON","unable to access uvm_config_db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    @(negedge aif.rst);
    forever begin 
      repeat(2)@(posedge aif.clk);
      t.din<=aif.din;
      t.dout<=aif.dout;
      `uvm_info("GEN",$sformatf("Data send to scoreboard din :%0d ",t.din), UVM_NONE); 
      send.write(t);
    end
  endtask 
endclass

 
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(transaction,scoreboard) recv;
  
  transaction data ;
  function new(string path="scoreboard",uvm_component parent=null);
    super.new(path,parent);
  endfunction 
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    data=transaction::type_id::create("trans");
  endfunction
  
  
  virtual function void write(transaction t);
    data=t;
    `uvm_info("GEN",$sformatf("Data rcvd from monitor din :%0d ",t.din), UVM_NONE); 
    if(data.dout==data.din)
      `uvm_info("SCO","test passed",UVM_NONE)
      else 
        `uvm_info("SCO","Test Failed", UVM_NONE);
endfunction
endclass

class agent extends uvm_agent ;
  `uvm_component_utils(agent)
  
  function new(string path="agent",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  monitor m ;
  driver d ;
  
  uvm_sequencer #(transaction) seq;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m=monitor::type_id::create("MON",this);
    d=driver::type_id::create("DRV",this);
    seq=uvm_sequencer#(transaction)::type_id::create("SEQ",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
    
    
  endfunction
endclass

class env extends uvm_env ;
  `uvm_component_utils(env)
  
  function new(string path="env",uvm_component parent=null);
    super.new(path,parent);
  endfunction 
  
  scoreboard s ;
  agent a ;
  
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
s= scoreboard::type_id::create("SCO",this);
a = agent::type_id::create("AGENT",this);
endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction 
endclass

class test extends uvm_test ;
  `uvm_component_utils(test)
  
  function new(string path="test",uvm_component parent = null );
    super.new(path,parent);
  endfunction
  
  generator gen ;
  env e ;
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gen=generator::type_id::create("gen",this);
    e=env::type_id::create("ENV",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seq);
    #60 ;
    phase.drop_objection(this);
  endtask 
endclass

module add_tb();
  ff aif();
  
  initial begin 
    aif.clk=0;
    aif.rst=0;
  end
  
  always #10 aif.clk=~aif.clk;
  dff dut (.din(aif.din),.clk(aif.clk), .rst(aif.rst),.dout(aif.dout));
  
initial begin
$dumpfile("dump.vcd");
$dumpvars;
end
  
  initial begin
    uvm_config_db#(virtual ff)::set(null,"*","aif",aif);
    run_test("test");
  end
  
endmodule
    
