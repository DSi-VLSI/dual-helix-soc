.SHELL: /bin/bash
export SHELL=/bin/bash

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

export DUAL_HELIX_SOC_DIR := $(CURDIR)
export APB_DIR            := $(DUAL_HELIX_SOC_DIR)/submodule/apb
export AXI_DIR            := $(DUAL_HELIX_SOC_DIR)/submodule/axi
export COMMON_CELLS_DIR   := $(DUAL_HELIX_SOC_DIR)/submodule/common_cells
export COMMON_DIR         := $(DUAL_HELIX_SOC_DIR)/submodule/common
export CV32E40P_DIR       := $(DUAL_HELIX_SOC_DIR)/submodule/cv32e40p
export CVFPU_DIR          := $(DUAL_HELIX_SOC_DIR)/submodule/cvfpu
export SOC_DIR            := $(DUAL_HELIX_SOC_DIR)/submodule/SoC

BUILD_DIR                 := $(DUAL_HELIX_SOC_DIR)/build
LOG_DIR                   := $(DUAL_HELIX_SOC_DIR)/log
FILE_LISTS                := $(shell find $(DUAL_HELIX_SOC_DIR)/hardware/filelist -type f -name "*.f")

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
	echo -e "\033[1;34mCompiling file list: $(shell basename $1):\033[0m ${LOG_DIR}/xvlog_$(shell basename $1 | sed 's/\.f$$//g').log"
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
	@$(foreach flist,${FILE_LISTS},$(call COMPILE_FLIST,$(flist));)
	@echo -e "\033[1;33mElaborating ${TOP}:\033[0m ${LOG_DIR}/elab_${TOP}.log"
	@cd ${BUILD_DIR} && ${XELAB} ${TOP} --debug all -s ${TOP} -log ${LOG_DIR}/elab_${TOP}.log --timescale 1ns/1ps ${EW_O}
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
	@$(eval TEST_PATH := $(shell find ${DUAL_HELIX_SOC_DIR}/software/source -type f -name "*${TEST}*"))
	@if [ -z "${TEST_PATH}" ]; then echo -e "\033[1;31mTest file ${TEST} not found!\033[0m"; exit 1; fi
	@if [ $$(echo "${TEST_PATH}" | wc -w) -gt 1 ]; then echo -e "\033[1;31mMultiple test files found for ${TEST}:\n${TEST_PATH}\033[0m"; exit 1; fi
	@${RISCV64_GCC} -march=rv32imf -mabi=ilp32f -nostdlib -nostartfiles -T ${DUAL_HELIX_SOC_DIR}/software/linkers/core_${HART_ID}.ld -o ${BUILD_DIR}/prog_${HART_ID}.elf ${TEST_PATH} ${DUAL_HELIX_SOC_DIR}/software/include/startup.S -I ${DUAL_HELIX_SOC_DIR}/software/include
	@${RISCV64_OBJCOPY} -O verilog ${BUILD_DIR}/prog_${HART_ID}.elf ${BUILD_DIR}/prog_${HART_ID}.hex
	@${RISCV64_NM} -n ${BUILD_DIR}/prog_${HART_ID}.elf > ${BUILD_DIR}/prog_${HART_ID}.sym
	@${RISCV64_OBJDUMP} -d ${BUILD_DIR}/prog_${HART_ID}.elf > ${BUILD_DIR}/prog_${HART_ID}.dis

# Print ASCII logo
.PHONY: print_logo
print_logo:
	@echo -e "\033[1;34m    ___  __  _____   __     __ ________   _____  __  ________  _____ \033[0m"
	@echo -e "\033[1;34m   / _ \/ / / / _ | / /    / // / __/ /  /  _/ |/_/ / __/ __ \/ ___/ \033[0m"
	@echo -e "\033[1;38m  / // / /_/ / __ |/ /__  / _  / _// /___/ /_>  <  _\ \/ /_/ / /__   \033[0m"
	@echo -e "\033[1;34m /____/\____/_/ |_/____/ /_//_/___/____/___/_/|_| /___/\____/\___/   \033[0m"
	@echo -e "\033[1;34m                                                                     \033[0m"

####################################################################################################
# CUSTOM TARGETS
####################################################################################################

test_hello_world_x2:
	@make -s ${BUILD_DIR}/build_$(TOP) TOP=dual_helix_soc_tb
	@rm -f ${BUILD_DIR}/prog_*.*
	@make -s test TEST=hello.c HART_ID=0
	@make -s test TEST=hello.c HART_ID=1
	@make -s simulate TOP=dual_helix_soc_tb TEST=$@ DEBUG=${DEBUG} GUI=${GUI}
