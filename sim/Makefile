PRESENT_DIR ?= ${PWD}/../..
BEFORE_SIM := ${PRESENT_DIR}/sim

TB_SRC_DIR := ${BEFORE_SIM}/src
SOURCE_DIRS := ${TB_SRC_DIR} ${PRESENT_DIR}/src


FILELIST_DIR := ${BEFORE_SIM}/filelist
RUN_DIR := ${BEFORE_SIM}/run
LOG_DIR := ${BEFORE_SIM}/log

INC_DIR := +incdir+${SRC_DIR}


FILELIST := ${FILELIST_DIR}/filelist.f
SIMV := ${RUN_DIR}/simv

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
	cd ${RUN_DIR} && vcs -kdb $(COMP_OPT) $(INC_DIR) -f $(FILELIST) | tee ${LOG_DIR}/compilation.log

sim: comp 
	cd ${RUN_DIR} && ${SIMV}  | tee ${LOG_DIR}/simulation.log

sim_debug: comp
	cd ${RUN_DIR} && ${SIMV} -gui -full64

verdi: sim
	cd ${RUN_DIR} && verdi -sverilog +v2k $(INC_DIR) -f $(FILELIST) -ssf ${RUN_DIR}/mvu.fsdb

clean:
	find ${RUN_DIR} -mindepth 1 -not -name '.gitignore' -exec rm -rf {} +
	find ${LOG_DIR} -mindepth 1 -not -name '.gitignore' -exec rm -rf {} +

