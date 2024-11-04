PRESENT_DIR := ${PWD}
SYN_FOLDER_DIR := ${PRESENT_DIR}/syn
BSIM_FOLDER_DIR := ${PRESENT_DIR}/sim
ASIM_FOLDER_DIR := ${PRESENT_DIR}/sim/asim

mode ?= default

# Default make goal
.DEFAULT_GOAL := run_syn

run_syn_init:
	@echo "Init design compiler synthesis"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} mode=${mode} -C $(SYN_FOLDER_DIR) init

run_syn:
	@echo "Building design compiler synthesis"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} mode=${mode} -C $(SYN_FOLDER_DIR) run_syn

clean_syn:
	@echo "Cleaning synthesis result"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} mode=wire -C $(SYN_FOLDER_DIR) clean

clean_synrun:
	@echo "Cleaning synthesis result"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} mode=wire -C $(SYN_FOLDER_DIR) clean_run

run_bsim_debug:
	@echo "Runing before synthesis sim"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} -C $(BSIM_FOLDER_DIR) sim_debug

run_bsim:
	@echo "Runing before synthesis sim"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} -C $(BSIM_FOLDER_DIR) verdi

clean_bsim:
	@echo "Cleaning before synthesis sim"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} -C $(BSIM_FOLDER_DIR) clean

run_asim:
	@echo "Runing after synthesis sim"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} -C $(ASIM_FOLDER_DIR) sim

clean_asim:
	@echo "Cleaning after synthesis sim"
	$(MAKE) PRESENT_DIR=${PRESENT_DIR} -C $(ASIM_FOLDER_DIR) clean



help:
	@echo "*****************************************************************"
	@echo "*****************************************************************"
	@echo "***************       SYN process       *************************"
	@echo "**make run_syn_init: Init design compiler synthesis *************"
	@echo "**make run_syn: Building design compiler synthesis  *************"
	@echo "**              -mode : wire / topo                  ************"
	@echo "**make clean_syn: Cleaning synthesis result & run   *************"
	@echo "**make clean_synrun: Cleaning synthesis result      *************"
	@echo "*****************************************************************"	
	@echo "*****************************************************************"	
	@echo "***************      BSIM process       *************************"
	@echo "**make run_bsim: Running Before Synthesis SIM       *************"
	@echo "**make run_bsim_debug: Running Before Synthesis SIM DEBUG********"
	@echo "**make clean_bsim: Cleaning Before Synthesis SIM DEBUG   ********"
	@echo "*****************************************************************"
	@echo "*****************************************************************"	
	@echo "***************      ASIM process       *************************"
	@echo "**make run_asim: Running After Synthesis SIM        *************"
	@echo "**make clean_asim: Cleaning After Synthesis SIM DEBUG    ********"
	@echo "*****************************************************************"
	@echo "*****************************************************************"

.PHONY: run_syn clean_syn

