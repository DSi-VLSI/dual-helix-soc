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
XSIM ?= xsim

####################################################################################################
# Directories
####################################################################################################

export DUAL_HELIX_SOC_DIR := $(CURDIR)
export COMMON_CELLS_DIR   := $(DUAL_HELIX_SOC_DIR)/submodule/common_cells
export CV32E40P_DIR       := $(DUAL_HELIX_SOC_DIR)/submodule/cv32e40p
export CVFPU_DIR          := $(DUAL_HELIX_SOC_DIR)/submodule/cvfpu

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

.PHONY: flist
flist:
	@echo "-i \$${DUAL_HELIX_SOC_DIR}/include" > ${FILE_LIST_DIR}/interface.f
	@find interface -type f -name "*.*v*" | sed "s/^/$$\{DUAL_HELIX_SOC_DIR\}\//g" >> ${FILE_LIST_DIR}/interface.f
	@echo "-i \$${DUAL_HELIX_SOC_DIR}/include" > ${FILE_LIST_DIR}/dhs.f
	@find source -type f -name "*.*v*" | sed "s/^/$$\{DUAL_HELIX_SOC_DIR\}\//g" >> ${FILE_LIST_DIR}/dhs.f
	@echo "-i \$${DUAL_HELIX_SOC_DIR}/include" > ${FILE_LIST_DIR}/testbench.f
	@find testbench -type f -name "*.*v*" | sed "s/^/$$\{DUAL_HELIX_SOC_DIR\}\//g" >> ${FILE_LIST_DIR}/testbench.f
	@git add ${FILE_LIST_DIR}/interface.f &> /dev/null
	@git add ${FILE_LIST_DIR}/dhs.f &> /dev/null
	@git add ${FILE_LIST_DIR}/testbench.f &> /dev/null

.PHONY: all
all:
	@make -s ${BUILD_DIR}
	@make -s ${LOG_DIR}
	@make -s flist
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/cv32e40p.f -log ${LOG_DIR}/xvlog_cv32e40p.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/interface.f -log ${LOG_DIR}/xvlog_interface.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/dhs.f -log ${LOG_DIR}/xvlog_dhs.log
	@cd ${BUILD_DIR} && ${XVLOG} -sv -f ${FILE_LIST_DIR}/testbench.f -log ${LOG_DIR}/xvlog_testbench.log
	@cd ${BUILD_DIR} && ${XELAB} ${TOP} --debug all -s ${TOP} -log ${LOG_DIR}/elab_${TOP}.log
	@cd ${BUILD_DIR} && ${XSIM} ${TOP} -runall -log ${LOG_DIR}/xsim_${TOP}.log

