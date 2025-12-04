.SHELL: /bin/bash

####################################################################################################
# Variables
####################################################################################################

TOP := dummy_tb
GUI := 0
HART_ID := 0

ifeq ($(GUI), 0) 
	SIM_MODE := -runall
else
	SIM_MODE := -gui
endif

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
export AXI_DIR            := $(DUAL_HELIX_SOC_DIR)/submodule/axi
export COMMON_CELLS_DIR   := $(DUAL_HELIX_SOC_DIR)/submodule/common_cells
export COMMON_DIR         := $(DUAL_HELIX_SOC_DIR)/submodule/common
export CV32E40P_DIR       := $(DUAL_HELIX_SOC_DIR)/submodule/cv32e40p
export CVFPU_DIR          := $(DUAL_HELIX_SOC_DIR)/submodule/cvfpu
export SOC_DIR            := $(DUAL_HELIX_SOC_DIR)/submodule/SoC

BUILD_DIR                 := $(DUAL_HELIX_SOC_DIR)/build
LOG_DIR                   := $(DUAL_HELIX_SOC_DIR)/log
FILE_LIST_DIR             := $(DUAL_HELIX_SOC_DIR)/hardware/filelist

####################################################################################################
# Rules
####################################################################################################

.PHONY: clean
clean:
	@rm -rf ${BUILD_DIR}
	@rm -rf ${LOG_DIR}

${BUILD_DIR}:
	@mkdir -p ${BUILD_DIR}
	@echo "*" > ${BUILD_DIR}/.gitignore

${LOG_DIR}:
	@mkdir -p ${LOG_DIR}
	@echo "*" > ${LOG_DIR}/.gitignore

.PHONY: simulate
simulate:
	@cd ${BUILD_DIR} && ${XSIM} ${TOP} ${SIM_MODE} -log ${LOG_DIR}/xsim_${TOP}.log

.PHONY: compile
compile: 
	@make -s ${BUILD_DIR}
	@make -s ${LOG_DIR}
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/interface.f -log ${LOG_DIR}/xvlog_interface.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/axi.f -log ${LOG_DIR}/xvlog_axi.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/cv32e40p.f -log ${LOG_DIR}/xvlog_cv32e40p.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/ss.f -log ${LOG_DIR}/xvlog_ss.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/dhs.f -log ${LOG_DIR}/xvlog_dhs.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/testbench.f -log ${LOG_DIR}/xvlog_testbench.log
	@cd ${BUILD_DIR} && ${XELAB} ${TOP} --debug all -s ${TOP} -log ${LOG_DIR}/elab_${TOP}.log --timescale 1ns/1ps

.PHONY: all
all:
	@make -s compile TOP=${TOP}
	@make -s simulate TOP=${TOP}

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
