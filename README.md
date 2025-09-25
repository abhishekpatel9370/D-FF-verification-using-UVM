# D-FF-verification-using-UVM  

This project implements and verifies a **D Flip-Flop (D-FF)** using **SystemVerilog and UVM (Universal Verification Methodology)**.  

## Design Description  
- The RTL design is a simple **D Flip-Flop** with synchronous reset.  
- On every positive clock edge:  
  - If `rst = 1`, output `dout` is reset to 0.  
  - Else, `dout` follows input `din`.  

## Verification Environment (UVM)  
The testbench is built using **UVM methodology** with the following components:  
- **Transaction** – Defines the input (`din`) and output (`dout`) data.  
- **Generator** – Creates and randomizes transactions.  
- **Driver** – Drives stimulus (`din`) to the DUT through the interface.  
- **Monitor** – Observes `din` and `dout` from the DUT.  
- **Scoreboard** – Checks DUT functionality by comparing `dout` with expected output.  
- **Agent** – Groups sequencer, driver, and monitor.  
- **Environment** – Instantiates agent and scoreboard, connects them.  
- **Test** – Creates environment, starts the sequence, and runs simulation.  
- **Top Testbench** – Instantiates DUT, clock, reset, interface, and triggers UVM test.  

## How to Run  
1. Clone the repository  
   ```bash
   git clone <your-repo-link>
   cd <repo-folder>
