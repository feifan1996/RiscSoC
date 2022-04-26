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
	@echo -e ${COLORS}[INFO] compile c/asm file ...${COLORE}
	${Q}${CC} ${INCFILES} ${CFLAGS} ${LDFLAGS} ${LDLIBS} ${ASMFILES} ${CFILES} -o ${TARGET}.elf
	@echo -e ${COLORS}[INFO] create dump file ...${COLORE}
	${Q}${OBJDUMP} -D -S ${TARGET}.elf > ${TARGET}.dump
	@echo -e ${COLORS}[INFO] create image file ...${COLORE}
	${Q}${OBJCOPY} -S -O binary  ${TARGET}.elf ${TARGET}.bin
	${Q}${OBJCOPY} -S -O verilog ${TARGET}.elf image.pat
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
	${Q}${RM} *.elf *.o *.bin *.map
	${Q}${RM} *.dump *.data image.pat
	@echo -e ${COLORS}[INFO] execute done${COLORE}
