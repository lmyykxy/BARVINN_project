CURRENT_TIME := $(shell date +'%Y-%m-%d %H:%M:%S')

run_syn:
	cd work && dc_shell | tee ${CURRENT_TIME}_dc.log

clean:
	rm -rf ./work/elab ./work/*log