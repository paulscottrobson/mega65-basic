#
#		Build BASIC (EM4510)
#
rm dump.mem memory.dump uart.sock
pushd scripts
#python ftestgen.py >../testing/script.inc
python fscript.py >../testing/script.inc
popd
pushd ../emulator
sh build.sh
popd
64tass -q -c -D CPU=6502 -D INTERFACE=1 -b basic.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../emulator/em4510 rom.bin go
	python scripts/showxs.py
fi
