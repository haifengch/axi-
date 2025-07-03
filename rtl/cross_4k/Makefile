all: clean com sim verdi

TOP=cross_4k_if
FILELIST=./filelist.f
SIG_FILE=./signal.rc

VCS=vcs
VCS_FLAGS=-full64 -sverilog -f $(FILELIST) -R +v2k -debug_access+all \
			-timescale=1ns/1ps -fsdb +define+FSDB -l com.log

VERDI=verdi
VERDI_FLAGS=-f $(FILELIST) -ssf $(TOP).fsdb -nologo -sswr $(SIG_FILE)


clean:
	rm -rf csrc *.fsdb *.log *.daidir verdiLog *.conf simv *.key
 
com:
	$(VCS) $(VCS_FLAGS)
 
sim:
	./simv -l sim.log
 
verdi:
	$(VERDI) $(VERDI_FLAGS) &
