.SHELL: /bin/bash

####################################################################################################
# Variables
####################################################################################################

TOP := dummy_tb

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
FILE_LIST_DIR             := $(DUAL_HELIX_SOC_DIR)/filelist

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

.PHONY: all
all:
	@make -s ${BUILD_DIR}
	@make -s ${LOG_DIR}
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/cv32e40p.f -log ${LOG_DIR}/xvlog_cv32e40p.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/interface.f -log ${LOG_DIR}/xvlog_interface.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/dhs.f -log ${LOG_DIR}/xvlog_dhs.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/testbench.f -log ${LOG_DIR}/xvlog_testbench.log
	@cd ${BUILD_DIR} && ${XELAB} ${TOP} --debug all -s ${TOP} -log ${LOG_DIR}/elab_${TOP}.log
	@cd ${BUILD_DIR} && ${XSIM} ${TOP} -runall -log ${LOG_DIR}/xsim_${TOP}.log

