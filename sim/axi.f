# -----------------------------------------------------------------------------
# Compile filelist for the AXI UVM Verification IP
# Usage (Vivado xvlog / xelab example, see sim/Makefile):
#   xvlog -sv -L uvm -f axi.f
# -----------------------------------------------------------------------------

# Include directories (needed because the package/env files pull in their
# children with `include, so every folder that owns an included file must
# be visible on the include path)
+incdir+../src
+incdir+../src/env
+incdir+../src/agents/master
+incdir+../src/agents/slave
+incdir+../src/sequences
+incdir+../src/tb

# Top-level testbench file.
# axi_tb_top.sv pulls in axi_package.svh, which in turn `includes every
# class in the environment (transaction, sequences, driver/monitor,
# agents, scoreboard, env, tests) in the correct dependency order, so it
# is the only file that needs to be handed to the compiler explicitly.
../src/tb/axi_tb_top.sv
