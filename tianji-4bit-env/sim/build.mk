#/*
# * Copyright {c} 2020-2021, SERI Development Team
# *
# * SPDX-License-Identifier: Apache-2.0
# *
# * Change Logs:
# * Date         Author          Notes
# * 2022-04-04   Lyons           first version
# */

COLORS = "\033[32m"
COLORE = "\033[0m"

.PHONY: run
run:
	@echo -e ${COLORS}[INFO] compile design file ...${COLORE}
	${Q}${VCS} -g2012 -o wave.vvp ${ALLDEFINE} -f ${PROJPATH}/scripts/model.filelist ${TBFILES}
	@echo -e ${COLORS}[INFO] create vvp file and vsim ...${COLORE}
	${Q}${SIM} -n wave.vvp -lxt2
	@echo -e ${COLORS}[INFO] execute done${COLORE}

.PHONY: wave
wave:
	${Q}${WAV} wave.vcd &

.PHONY: help
help:
	@echo "help     - help menu         "
	@echo "run      - compile and run   "
	@echo "wave     - open gtkwave      "

.PHONY: clean
clean:
	@echo -e ${COLORS}[INFO] clean project ...${COLORE}
	${Q}${RM} *.vvp *.vcd *.lxt*
	@echo -e ${COLORS}[INFO] execute done${COLORE}
