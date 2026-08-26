# -----------------------------------------------------------------------------
# Makefile for the AXI UVM VIP  (Xilinx Vivado xvlog/xelab/xsim flow)
#
# Usage:
#   make          run axi_base_test with the default GUI-less regression
#   make gui      run axi_base_test and open the waveform viewer
#   make TEST=axi_wrap_test   run a specific UVM_TESTNAME
#   make clean    remove all generated simulation artifacts
#
# Requires Vivado's simulator (xvlog/xelab/xsim) and a UVM 1.2 library
# on PATH. Tested with the bundled UVM that ships with Vivado
# (-L uvm below).
# -----------------------------------------------------------------------------

TEST      ?= axi_base_test
TOP        = top
FILELIST   = axi.f
WORKDIR    = xsim_work
WAVE_CFG   = ../sim/waves/top_behav.wcfg

.PHONY: all compile elaborate run gui clean

all: run

compile:
	xvlog -sv -L uvm -f $(FILELIST) --work $(WORKDIR)

elaborate: compile
	xelab $(TOP) -s $(TOP)_sim -L uvm --debug typical --work $(WORKDIR)

run: elaborate
	xsim $(TOP)_sim -R --testplusarg UVM_TESTNAME=$(TEST) \
		| tee logs/simulate.log

gui: elaborate
	xsim $(TOP)_sim --gui --testplusarg UVM_TESTNAME=$(TEST)

clean:
	rm -rf xsim_work xsim.dir xelab.pb xsim.jou xsim.log \
	       webtalk* .Xil *.wdb *.jou *.log
