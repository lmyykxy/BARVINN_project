PRESENT_DIR ?= ${PWD}/../..
BEFORE_SIM := ${PRESENT_DIR}/sim

TB_SRC_DIR := ${BEFORE_SIM}/src
SOURCE_DIRS := ${TB_SRC_DIR} ${PRESENT_DIR}/src


FILELIST_DIR := ${BEFORE_SIM}/filelist
RUN_DIR := ${BEFORE_SIM}/run
LOG_DIR := ${BEFORE_SIM}/log

INC_DIR := +incdir+${SRC_DIR}


FILELISTmvu := ${FILELIST_DIR}/mvu_filelist.f 
FILELISTriscv := ${FILELIST_DIR}/riscv_filelist.f
FILELISTtb := ${FILELIST_DIR}/tb_filelist.f
SIMV := ${RUN_DIR}/simv

E203_INSTR_TESTCASE := ${PRESENT_DIR}/sim/data/helloworld/helloworld
# E203_INSTR_TESTCASE := ${PRESENT_DIR}/sim/data/rv32ui-p-xor
TOP_MODULE := riscv_top
# TOP_MODULE := testbench_top

COMP_OPT := -sverilog \
			+v2k \
			-full64 \
			-timescale=1ns/1ps \
			-debug_acc+all -debug_region+cell+encrypt \
			+notimingchecks \
			+nospecify \
			+lint=TFIPC-L \

generate_filelist:
	@echo "Generating filelist..."
	@rm -f $(FILELIST)
	@for dir in $(SOURCE_DIRS); do \
		find $$dir -type f -name "*.v" >> $(FILELIST); \
	done
	@echo "Filelist generated at $(FILELIST)"


comp: 
	cd ${RUN_DIR} && vcs -kdb $(COMP_OPT) $(INC_DIR) -f $(FILELISTmvu) -f $(FILELISTriscv) -f $(FILELISTtb) -top $(TOP_MODULE) | tee ${LOG_DIR}/compilation.log

sim: comp 
	cd ${RUN_DIR} && ${SIMV} +ntb_random_seed_automatic +TESTCASE=${E203_INSTR_TESTCASE}  | tee ${LOG_DIR}/simulation.log

sim_debug: comp
	cd ${RUN_DIR} && ${SIMV} -gui +ntb_random_seed_automatic +TESTCASE=${E203_INSTR_TESTCASE}

verdi: sim
	cd ${RUN_DIR} && verdi -sverilog +v2k $(INC_DIR) -f $(FILELISTmvu) -f $(FILELISTriscv) -f $(FILELISTtb) -ssf ${RUN_DIR}/${TOP_MODULE}.fsdb

clean:
	find ${RUN_DIR} -mindepth 1 -not -name '.gitignore' -exec rm -rf {} +
	find ${LOG_DIR} -mindepth 1 -not -name '.gitignore' -exec rm -rf {} +

