
VHD_DIR := vhd
CFG_DIR := config

APP_DIR := logiciel/apps
SRC_DIR := program
TMP_DIR := .CEPcache

RVDIR         ?= /matieres/3MMCEP/riscv
TOOLCHAIN_DIR := $(RVDIR)/bin
FEMTO_DIR     := $(RVDIR)

SIM_DIR := $(TMP_DIR)/sim
BIT_DIR := $(TMP_DIR)/bit
MEM_DIR := $(TMP_DIR)/mem
SYN_DIR := $(TMP_DIR)/synth
MUT_DIR := $(TMP_DIR)/mut
#RES_DIR := /tmp/CEP-$(shell whoami)

DIR ?= # Empty by default
DIR += $(SIM_DIR)
DIR += $(SYN_DIR)
DIR += $(BIT_DIR)
DIR += $(MEM_DIR)
#DIR += $(RES_DIR)

# Optional
#SYN_REPORT_DIR     := $(SYN_DIR)/report
#SYN_CHECKPOINT_DIR := $(SYN_DIR)/checkpoint
#$(SYN_REPORT_DIR) $(SYN_CHECKPOINT_DIR)

$(TMP_DIR):
	@mkdir -p $@
	@# Make symbolic link (if it doesn't already exist)
	@-ln -s -T $(abspath $(VHD_DIR)) $@/$(VHD_DIR)
	@-ln -s -T $(abspath $(CFG_DIR)) $@/$(CFG_DIR)

$(DIR):|$(TMP_DIR)
	@mkdir -p $@

