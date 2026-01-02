.SHELL: /bin/bash
export SHELL=/bin/bash

ifeq ($(VIVADO_PATH),)
  ${error VIVADO_PATH needs to be specified}
endif

# Makefile for Dual Helix SoC
# This Makefile provides targets for building, simulating, and testing the Dual Helix SoC.
# It uses Xilinx Vivado tools for compilation and simulation.

####################################################################################################
# Variables
####################################################################################################

TOP := dual_helix_soc_tb
TEST := default
DEBUG := 0
GUI := 0
HART_ID := 0
RAM_BDL := 1

ifeq ($(GUI), 0) 
	SIM_MODE := -runall
else
	SIM_MODE := -gui
endif

EW_HL := | grep -E "WARNING:|ERROR:|" --color=auto
EW_O := | grep -E "WARNING:|ERROR:" --color=auto || true

.DEFAULT_GOAL := help

####################################################################################################
# Tools
####################################################################################################

XVLOG ?= xvlog
XELAB ?= xelab
XSIM  ?= xsim

RISCV64_GCC     ?= riscv64-unknown-elf-gcc
RISCV64_OBJCOPY ?= riscv64-unknown-elf-objcopy
RISCV64_NM      ?= riscv64-unknown-elf-nm
RISCV64_OBJDUMP ?= riscv64-unknown-elf-objdump

####################################################################################################
# Directories
####################################################################################################

export DUAL_HELIX_SOC_DIR       := $(CURDIR)
export APB_DIR                  := $(DUAL_HELIX_SOC_DIR)/submodule/apb
export AXI_DIR                  := $(DUAL_HELIX_SOC_DIR)/submodule/axi
export COMMON_CELLS_DIR         := $(DUAL_HELIX_SOC_DIR)/submodule/common_cells
export COMMON_DIR               := $(DUAL_HELIX_SOC_DIR)/submodule/common
export CV32E40P_DIR             := $(DUAL_HELIX_SOC_DIR)/submodule/cv32e40p
export CVFPU_DIR                := $(DUAL_HELIX_SOC_DIR)/submodule/cvfpu
export SOC_DIR                  := $(DUAL_HELIX_SOC_DIR)/submodule/SoC
export CORE_DDR3_CONTROLLER_DIR := $(DUAL_HELIX_SOC_DIR)/submodule/core_ddr3_controller

BUILD_DIR                 := $(DUAL_HELIX_SOC_DIR)/build
LOG_DIR                   := $(DUAL_HELIX_SOC_DIR)/log
FILE_LISTS                := $(shell find $(DUAL_HELIX_SOC_DIR)/hardware/filelist -type f -name "pkg.f")
FILE_LISTS                += $(shell find $(DUAL_HELIX_SOC_DIR)/hardware/filelist -type f -name "*.f" ! -name "pkg.f")
DDR3_PRJ                  := $(DUAL_HELIX_SOC_DIR)/hardware/filelist/ddr3_axi_prj.prj 


####################################################################################################
# Rules
####################################################################################################

# Clean build and log directories
.PHONY: clean
clean:
	@rm -rf ${BUILD_DIR}

# Clean both build and log directories
.PHONY: clean_full
clean_full:
	@make -s clean
	@rm -rf ${LOG_DIR}

# Create build directory and gitignore
${BUILD_DIR}:
	@mkdir -p ${BUILD_DIR}
	@echo "*" > ${BUILD_DIR}/.gitignore

# Create log directory and gitignore
${LOG_DIR}:
	@mkdir -p ${LOG_DIR}
	@echo "*" > ${LOG_DIR}/.gitignore

# Macro to compile a file list using XVLOG
define COMPILE_FLIST
	echo -e "  \033[1;34m$(shell basename $1)\033[15G :\033[0m ${LOG_DIR}/xvlog_$(shell basename $1 | sed 's/\.f$$//g').log"
	cd ${BUILD_DIR} && ${XVLOG} -sv -d VERILATOR -d XSIM -f $1 -log ${LOG_DIR}/xvlog_$(shell basename $1 | sed 's/\.f$$//g').log ${EW_O}
endef

# Check if the build is up to date by comparing SHA sums of hardware files
.PHONY: match_sha
match_sha:
	@sha256sum $$(find hardware -type f) > ${BUILD_DIR}/build_$(TOP)_new
	@diff ${BUILD_DIR}/build_$(TOP)_new ${BUILD_DIR}/build_$(TOP) || make -s ENV_BUILD TOP=$(TOP)

# Perform a full environment build: clean, update submodules, compile file lists, elaborate design
.PHONY: ENV_BUILD
ENV_BUILD:
	@make -s clean
	@make -s ${BUILD_DIR}
	@make -s ${LOG_DIR}
	@git submodule update --init --depth 1
	@echo -e "\033[1;33mCompiling:\033[0m"
	@$(foreach flist,${FILE_LISTS},$(call COMPILE_FLIST,$(flist));)
	@echo -e "\033[1;33mElaborating ${TOP}:\033[0m ${LOG_DIR}/elab_${TOP}.log"
	@cd ${BUILD_DIR} && ${XELAB} -prj ${DDR3_PRJ} -L secureip -L unisims_ver -L unimacro_ver ${TOP} glbl --debug all -s ${TOP} -log ${LOG_DIR}/elab_${TOP}.log --timescale 1ns/1ps ${EW_O}
	@sha256sum $$(find hardware -type f) > ${BUILD_DIR}/build_$(TOP)

# Target to ensure the build is up to date
.PHONY: ${BUILD_DIR}/build_$(TOP)
${BUILD_DIR}/build_$(TOP):
	@if [ ! -f ${BUILD_DIR}/build_$(TOP) ]; then \
		make -s ENV_BUILD TOP=$(TOP); \
	else \
		make -s match_sha TOP=$(TOP); \
	fi

# Generate common simulation arguments
.PHONY: common_sim_checks
common_sim_checks:
	@echo "--testplusarg TEST=$(TEST)" > ${BUILD_DIR}/xsim_args
	@echo "--testplusarg DEBUG=$(DEBUG)" >> ${BUILD_DIR}/xsim_args
	@echo "--testplusarg RAM_BDL=${RAM_BDL}" >> ${BUILD_DIR}/xsim_args

# Run the simulation using XSIM
.PHONY: simulate
simulate:
	@make -s print_logo
	@make -s ${BUILD_DIR}/build_$(TOP)
	@make -s ${LOG_DIR}
	@make -s common_sim_checks
	@echo -e "\033[1;35mSimulating ${TOP}:\033[0m ${LOG_DIR}/xsim_${TOP}_${TEST}.log"
	@cd ${BUILD_DIR} && ${XSIM} ${TOP} ${SIM_MODE} -f xsim_args -log ${LOG_DIR}/xsim_${TOP}_${TEST}.log ${EW_HL}

# Compile and prepare test program using RISC-V GCC tools
.PHONY: test
test:
	@make -s ${BUILD_DIR}
	@$(eval TEST_PATH := $(shell find software/source -type f -name "*${TEST}*"))
	@if [ -z "${TEST_PATH}" ]; then echo -e "\033[1;31mTest file ${TEST} not found!\033[0m"; exit 1; fi
	@if [ $$(echo "${TEST_PATH}" | wc -w) -gt 1 ]; then echo -e "\033[1;31mMultiple test files found for ${TEST}:\n${TEST_PATH}\033[0m"; exit 1; fi
	@${RISCV64_GCC} -march=rv32imf -mabi=ilp32f -nostdlib -nostartfiles -T software/linkers/core_${HART_ID}.ld -o build/prog_${HART_ID}.elf software/include/startup.S ${TEST_PATH} -I software/include
	@${RISCV64_OBJCOPY} -O verilog build/prog_${HART_ID}.elf build/prog_${HART_ID}.hex
	@${RISCV64_NM} -n build/prog_${HART_ID}.elf > build/prog_${HART_ID}.sym
	@${RISCV64_OBJDUMP} -d build/prog_${HART_ID}.elf > build/prog_${HART_ID}.dis

# Print ASCII logo
.PHONY: print_logo
print_logo:
	@echo -e "\033[1;34m    ___  __  _____   __     __ ________   _____  __  ________  _____ \033[0m"
	@echo -e "\033[1;34m   / _ \/ / / / _ | / /    / // / __/ /  /  _/ |/_/ / __/ __ \/ ___/ \033[0m"
	@echo -e "\033[1;38m  / // / /_/ / __ |/ /__  / _  / _// /___/ /_>  <  _\ \/ /_/ / /__   \033[0m"
	@echo -e "\033[1;34m /____/\____/_/ |_/____/ /_//_/___/____/___/_/|_| /___/\____/\___/   \033[0m"
	@echo -e "\033[1;34m                                                                     \033[0m"

.PHONY: help
help:
	@echo -e "\033[1;33mAvailable Makefile targets:\033[0m"
	@echo -e "  \033[1;32mmake clean\033[0m           - Clean build directory"
	@echo -e "  \033[1;32mmake clean_full\033[0m      - Clean build and log directories"
	@echo -e "  \033[1;32mmake ENV_BUILD\033[0m       - Perform full environment build"
	@echo -e "  \033[1;32mmake simulate\033[0m        - Run simulation (set TEST, DEBUG, GUI as needed)"
	@echo -e "  \033[1;32mmake test TEST=<test.c> HART_ID=<id>\033[0m - Compile and prepare test program"
	@echo -e "  \033[1;32mmake help\033[0m            - Show this help message"
	@echo -e "  \033[1;32mmake test_hello_world_x2\033[0m - Run hello world test on dual HARTs"
	@echo -e "\033[1;33mEnvironment Variables:\033[0m"
	@echo -e "  \033[1;32mTOP\033[0m        - Top-level testbench module (default: dual_helix_soc_tb)"
	@echo -e "  \033[1;32mTEST\033[0m       - Test program to run (default: default)"
	@echo -e "  \033[1;32mDEBUG\033[0m      - Debug mode (0: off, 1: on; default: 0)"
	@echo -e "  \033[1;32mGUI\033[0m        - GUI mode for simulation (0: off, 1: on; default: 0)"
	@echo -e "  \033[1;32mHART_ID\033[0m    - HART ID for test program (default: 0)"
	@echo -e "  \033[1;32mRAM_BDL\033[0m   - RAM block depth multiplier (default: 1)"

####################################################################################################
# CUSTOM TARGETS
####################################################################################################

test_hello_world_x2:
	@make -s ${BUILD_DIR}/build_$(TOP) TOP=dual_helix_soc_tb
	@rm -f ${BUILD_DIR}/prog_*.*
	@make -s test TEST=hello.c HART_ID=0
	@make -s test TEST=hello.c HART_ID=1
	@make -s simulate TOP=dual_helix_soc_tb TEST=$@ DEBUG=${DEBUG} GUI=${GUI}
