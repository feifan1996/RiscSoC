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
	@echo -e ${COLORS}[INFO] compile core 0 ...${COLORE}
	@echo -e ${COLORS}[INFO] compile c/asm file ...${COLORE}
	${Q}${CC} ${INCFILES} ${CFLAGS} ${LDFLAGS0} ${LDLIBS} ${ASMFILES} ${CFILES} ${CFILES0} -o ${TARGET}_0.elf
	@echo -e ${COLORS}[INFO] create dump file ...${COLORE}
	${Q}${OBJDUMP} -D -S ${TARGET}_0.elf > ${TARGET}_0.dump
	@echo -e ${COLORS}[INFO] create image file ...${COLORE}
	${Q}${OBJCOPY} -S -O binary  ${TARGET}_0.elf ${TARGET}_0.bin
	${Q}${OBJCOPY} -S -O verilog ${TARGET}_0.elf image0.pat

	@echo -e ${COLORS}[INFO] compile core 1 ...${COLORE}
	@echo -e ${COLORS}[INFO] compile c/asm file ...${COLORE}
	${Q}${CC} ${INCFILES} ${CFLAGS} ${LDFLAGS1} ${LDLIBS} ${ASMFILES} ${CFILES} ${CFILES1} -o ${TARGET}_1.elf
	@echo -e ${COLORS}[INFO] create dump file ...${COLORE}
	${Q}${OBJDUMP} -D -S ${TARGET}_1.elf > ${TARGET}_1.dump
	@echo -e ${COLORS}[INFO] create image file ...${COLORE}
	${Q}${OBJCOPY} -S -O binary  ${TARGET}_1.elf ${TARGET}_1.bin
	${Q}${OBJCOPY} -S -O verilog ${TARGET}_1.elf image1.pat

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
	${Q}${RM} *.dump *.data *.pat
	@echo -e ${COLORS}[INFO] execute done${COLORE}
