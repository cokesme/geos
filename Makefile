AS=~/Documents/cc65/bin/ca65
LD=~/Documents/cc65/bin/ld65

ASFLAGS=--include-dir inc

KERNAL_SOURCES= \
src/kernal/init.s \
src/kernal/bswfont.s \
src/kernal/icons.s \
src/kernal/lokernal.s \
src/kernal/patterns.s \
src/kernal/unknown.s \
src/kernal/conio.s \
src/kernal/dlgbox.s \
src/kernal/files.s \
src/kernal/fonts.s \
src/kernal/graph.s \
src/kernal/icon.s \
src/kernal/main.s \
src/kernal/math.s \
src/kernal/memory.s \
src/kernal/menu.s \
src/kernal/mouseio.s \
src/kernal/process.s \
src/kernal/sprites.s \
src/kernal/system.s

DEPS=inc/const.inc inc/diskdrv.inc inc/equ.inc inc/geosmac.inc inc/geossym.inc inc/kernal.inc inc/printdrv.inc

KERNAL_OBJECTS=$(KERNAL_SOURCES:.s=.o)

ALL_BINS=kernal.bin drv1541.bin drv1571.bin drv1581.bin amigamse.bin joydrv.bin lightpen.bin mse1531.bin combined.prg compressed.prg geos.d64

all: geos.d64

clean:
	rm -f $(KERNAL_OBJECTS) $(ALL_BINS) combined.prg

geos.d64: compressed.prg
	c1541 <c1541.in >/dev/null

compressed.prg: combined.prg
	pucrunch -f -c64 -x0x5000 $< $@

combined.prg: $(ALL_BINS)
	printf "\x00\x50" > tmp.bin
	dd if=kernal.bin bs=1 count=16384 >> tmp.bin
	cat drv1541.bin /dev/zero | dd bs=1 count=3456 >> tmp.bin
	cat kernal.bin /dev/zero | dd bs=1 skip=19840 count=24832 >> tmp.bin
	cat joydrv.bin >> tmp.bin
	mv tmp.bin combined.prg

kernal.bin: $(KERNAL_OBJECTS) src/kernal/kernal.cfg
	$(LD) -C src/kernal/kernal.cfg $(KERNAL_OBJECTS) -o $@

drv1541.bin: src/drv/drv1541.o src/drv/drv1541.cfg
	$(LD) -C src/drv/drv1541.cfg src/drv/drv1541.o -o $@

drv1571.bin: src/drv/drv1571.o src/drv/drv1571.cfg
	$(LD) -C src/drv/drv1571.cfg src/drv/drv1571.o -o $@

drv1581.bin: src/drv/drv1581.o src/drv/drv1581.cfg
	$(LD) -C src/drv/drv1581.cfg src/drv/drv1581.o -o $@

amigamse.bin: src/input/amigamse.o src/input/amigamse.cfg
	$(LD) -C src/input/amigamse.cfg src/input/amigamse.o -o $@

joydrv.bin: src/input/joydrv.o src/input/joydrv.cfg
	$(LD) -C src/input/joydrv.cfg src/input/joydrv.o -o $@

lightpen.bin: src/input/lightpen.o src/input/lightpen.cfg
	$(LD) -C src/input/lightpen.cfg src/input/lightpen.o -o $@

mse1531.bin: src/input/mse1531.o src/input/mse1531.cfg
	$(LD) -C src/input/mse1531.cfg src/input/mse1531.o -o $@

%.o: %.s $(DEPS)
	$(AS) $(ASFLAGS) $< -o $@

# a must!
love:	
	@echo "Not war, eh?"
