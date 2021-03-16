# Parametres de simulation
TOP     ?= PROC
TIME    ?= 10000ns
MUTANTS ?= 0

TOP_OK := PROC autotest
ifeq ($(filter $(TOP),$(TOP_OK)),)
  $(error "Design toplevel inconnu: $(TOP)\n")
endif

TOOLCHAIN ?= vivado
TOOLCHAIN_LIST := vivado # ghdl
ifeq ($(filter $(TOOLCHAIN),$(TOOLCHAIN_LIST)),)
  $(error Toolchain de simulation inconnue: $(TOOLCHAIN))
endif

# Xilinx tools
ifeq ($(origin XILINX_VIVADO), undefined)
  $(error "Outils Xilinx introuvables, lancez d'abord la commande: 'source /bigsoft/Xilinx/Vivado/2019.1/settings64.sh'")
endif
XILINX_PREFIX ?= $(XILINX_VIVADO)/bin/

# Log level
VERB ?= 0
LOG_FILE := $(abspath $(LOG))
include config/quiet.mk

TOCLEAN:=$(filter xsim% %.log %.jou,$(wildcard *)) $(LOG)
TOPOLISH:=.Xil

# Main rule
all: trace

.PHONY: analysis elaboration run trace


# Fichier sources
include config/directory.mk

PRJ := $(abspath config/tb_$(TOP)_beh.prj)
VHD := $(shell sed -e 's/vhdl work \(.*\)/\1 /' $(PRJ))

SIM_SCRIPT ?= config/simulation.xsim.tcl
override SIM_SCRIPT := $(abspath $(SIM_SCRIPT))
VCD_FILE := $(SIM_DIR)/trace.vcd


# Global rules
analysis: analyses_$(TOOLCHAIN)
elaboration: elaboration_$(TOOLCHAIN)
run: run_$(TOOLCHAIN)
GUI: GUI_$(TOOLCHAIN)


### Simulateur GHDL
# /!\ Doesn't work with Xilinx libs
analysis_ghdl: $(PRJ) | $(SIM_DIR)
	cd $(SIM_DIR) ; ghdl -a -g --ieee=synopsys $(VHD)

elaboration_ghdl: | analysis_ghdl $(SIM_DIR)
	cd $(SIM_DIR) ; ghdl -m --ieee=synopsys $(TOP)

run_ghdl: export VCD_FILE := $(abspath $(VCD_FILE))
run_ghdl: | elaboration_ghdl $(SIM_DIR)
	cd $(SIM_DIR) ; ghdl -r --ieee=synopsys $(TOP)


### Simulateur Xilinx
analysis_vivado: $(PRJ) | $(SIM_DIR)
	@echo "Analysis.."
	@cd $(SIM_DIR) ; $(XILINX_PREFIX)xvhdl --2008 -prj $(PRJ) -nolog -initfile=$(XILINX_VIVADO)/data/xsim/ip/xsim_ip.ini -L xpm | tee -a $(LOG) | grep -E "^ERROR" ; exit $$(( ! $$? ))

elaboration_vivado: | analysis_vivado $(SIM_DIR)
	$(call quiet-command, cd $(SIM_DIR) ; $(XILINX_PREFIX)xelab tb_$(TOP) -initfile=$(XILINX_VIVADO)/data/xsim/ip/xsim_ip.ini -L xpm -nolog -debug typical -generic_top "mutant=${MUTANTS}", "Elaborate..")

run_vivado: export TIME     := $(TIME)
run_vivado: export VCD_FILE := $(abspath $(VCD_FILE))
run_vivado: | elaboration $(SIM_DIR)
	$(call quiet-command, cd $(SIM_DIR) ; $(XILINX_PREFIX)xsim tb_$(TOP) -nolog -t $(SIM_SCRIPT) -wdb trace.wdb, "Simulation with xsim..")

GUI_vivado: | elaboration_vivado $(SIM_DIR)
	$(call quiet-command, cd $(SIM_DIR) ; $(XILINX_PREFIX)xsim tb_$(TOP) -nolog -gui -view ../config/tb_$(TOP)_xsim_beh.wcfg, "Start xsim GUI..")


# Trace VCD file
trace: | run
	gtkwave $(VCD_FILE) --save=config/tb_$(TOP).gtkw &

clean:
	echo "Removing $(TOCLEAN)"
	rm -rf $(TOCLEAN)

realclean: clean
	echo "Removing $(TOPOLISH)"
	rm -rf $(TOPOLISH)
