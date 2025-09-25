# D-FF-verification-using-UVM  

🔍 **UVM Testbench Architecture**  

The verification environment is built using standard UVM components:

- **Transaction (transaction)** → Defines the stimulus (din, dout).  
- **Generator (generator)** → Randomizes and creates transactions.  
- **Driver (driver)** → Drives din into DUT via the interface.  
- **Monitor (monitor)** → Observes din and dout signals and forwards them.  
- **Scoreboard (scoreboard)** → Compares dout with expected behavior (dout should equal din).  
- **Agent (agent)** → Groups driver, monitor, and sequencer.  
- **Environment (env)** → Connects agent and scoreboard.  
- **Test (test)** → Creates environment and runs the sequence.  
- **Top Testbench (add_tb)** → Instantiates DUT, clock, reset, interface, and calls run_test.  

📐 **UVM Testbench Block Diagram**  

lua
Copy code
        +-------------------+
        |       Test        |
        +---------+---------+
                  |
                  v
        +-------------------+
        |    Environment    |
        +---------+---------+
                  |
  +---------------+---------------+
  |                               |
  v                               v
+---------------+ +---------------+
| Agent | | Scoreboard |
+-------+-------+ +-------+-------+
| ^
+------+-------+ |
| | |
v v |
+------+ +-----------+ |
|Driver| | Monitor |-----------------+
+------+ +-----------+
|
v
+------------------+
| DUT |
| (D Flip-Flop) |
+------------------+

arduino
Copy code

📂 **File Structure**
├── dff.sv # RTL Design of D Flip-Flop
├── tb.sv # Top-level testbench (instantiates DUT + interface + run_test)
├── uvm_tb.sv # All UVM classes (transaction, driver, monitor, scoreboard, env, test, etc.)
├── dump.vcd # Waveform dump (generated after simulation)
└── README.md # Project documentation

bash
Copy code

▶️ **How to Run**  

1. Clone the Repository  
   ```bash
   git clone <your-repo-link>
   cd <repo-folder>
Compile & Run Simulation (Example with QuestaSim; update if using another simulator)

bash
Copy code
vlog dff.sv tb.sv uvm_tb.sv +incdir+$UVM_HOME/src
vsim -c -do "run -all" add_tb
View Waveforms (Optional)

bash
Copy code
gtkwave dump.vcd
✅ Expected Behavior

Driver applies randomized din values to DUT.

Monitor captures din and dout.

Scoreboard checks correctness:

If dout == din → Test Passed

Else → Test Failed

📜 Example UVM Log

yaml
Copy code
UVM_INFO @ 0: GEN [GEN] Data sent to DUT din: 1
UVM_INFO @ 20: MON [MON] Data observed din=1 dout=1
UVM_INFO @ 20: SCO [SCO] Test Passed
📖 Learning Outcomes

RTL design of a D Flip-Flop in Verilog.

Complete UVM testbench development: Transaction, Generator, Driver, Monitor, Scoreboard.

Agent & Environment hierarchy.

Hands-on use of uvm_config_db for virtual interface passing.

Stimulus generation, monitoring, and functional checking with UVM.
